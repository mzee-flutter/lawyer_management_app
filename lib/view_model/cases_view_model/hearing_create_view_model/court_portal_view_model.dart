// lib/viewmodels/court_portal_viewmodel.dart
//
// Drives the entire Court Portal screen.
// Follows your AgendaViewModel / CalendarViewModel pattern.
//
// Two domains, one ViewModel — they share the same screen.
// Tab selection (roster vs copies) is state here, not in the widget.

import 'package:flutter/foundation.dart';

import '../../../models/case_models/court_portal_model.dart';
import '../../../repository/case_repository/hearing_repository/court_portal_repo.dart';

enum CourtPortalTab { roster, copies }

enum CopyFilter { all, applied, processing, ready }

extension CopyFilterX on CopyFilter {
  String? get apiValue {
    switch (this) {
      case CopyFilter.all:
        return null;
      case CopyFilter.applied:
        return 'applied';
      case CopyFilter.processing:
        return 'processing';
      case CopyFilter.ready:
        return 'ready';
    }
  }

  String get label {
    switch (this) {
      case CopyFilter.all:
        return 'All';
      case CopyFilter.applied:
        return 'Applied';
      case CopyFilter.processing:
        return 'Processing';
      case CopyFilter.ready:
        return 'Ready';
    }
  }
}

class CourtPortalViewModel extends ChangeNotifier {
  final CourtPortalRepository _courtPortalRepository = CourtPortalRepository();

  // ─────────────────────────────────────────────
  // Tab state
  // ─────────────────────────────────────────────
  CourtPortalTab _activeTab = CourtPortalTab.roster;
  CourtPortalTab get activeTab => _activeTab;

  void switchTab(CourtPortalTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
    // Lazy-load the tab's data on first switch
    if (tab == CourtPortalTab.roster && _roster == null && !_isRosterLoading) {
      loadRoster();
    }
    if (tab == CourtPortalTab.copies && _copies == null && !_isCopiesLoading) {
      loadCopies();
    }
  }

  //------------------------------

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggleExpand() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  String? _selectedCaseId;
  String? get selectedCaseId => _selectedCaseId;

  void getSelectedCaseId(String? value) {
    _selectedCaseId = value;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Bench Roster state
  // ─────────────────────────────────────────────
  BenchRosterModel? _roster;
  bool _isRosterLoading = false;
  String? _rosterError;

  BenchRosterModel? get roster => _roster;
  bool get isRosterLoading => _isRosterLoading;
  String? get rosterError => _rosterError;

  Future<void> loadRoster() async {
    _isRosterLoading = true;
    _rosterError = null;
    notifyListeners();
    try {
      _roster = await _courtPortalRepository.getBenchRoster();
    } catch (e) {
      _rosterError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRosterLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRoster() async {
    _roster = null;
    await loadRoster();
  }

  // ─────────────────────────────────────────────
  // Certified Copies state
  // ─────────────────────────────────────────────
  List<CertifiedCopyModel>? _copies;
  bool _isCopiesLoading = false;
  String? _copiesError;
  CopyFilter _activeFilter = CopyFilter.all;

  List<CertifiedCopyModel>? get copies => _copies;
  bool get isCopiesLoading => _isCopiesLoading;
  String? get copiesError => _copiesError;
  CopyFilter get activeFilter => _activeFilter;

  // Filtered view — applied client-side from the full list
  List<CertifiedCopyModel> get filteredCopies {
    if (_copies == null) return [];
    if (_activeFilter == CopyFilter.all) return _copies!;
    return _copies!
        .where((c) => c.status.apiLabel == _activeFilter.apiValue)
        .toList();
  }

  // Counts per status — for the filter chip badges
  int countByStatus(CopyFilter filter) {
    if (_copies == null) return 0;
    if (filter == CopyFilter.all) return _copies!.length;
    return _copies!.where((c) => c.status.apiLabel == filter.apiValue).length;
  }

  Future<void> loadCopies() async {
    _isCopiesLoading = true;
    _copiesError = null;
    notifyListeners();
    try {
      // Always load all copies — filter client-side for instant tab switching
      _copies = await _courtPortalRepository.getAllCopies();
    } catch (e) {
      _copiesError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isCopiesLoading = false;
      notifyListeners();
    }
  }

  void setFilter(CopyFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Create copy — with optimistic insert
  // ─────────────────────────────────────────────
  bool _isCreating = false;
  String? _createError;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  Future<bool> createCopy({
    required String caseId,
    required String referenceNumber,
    String? description,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();
    try {
      final newCopy = await _courtPortalRepository.createCopy(
        caseId: caseId,
        referenceNumber: referenceNumber,
        description: description,
      );
      // Prepend to list — newest first
      _copies = [newCopy, ...(_copies ?? [])];
      return true;
    } catch (e) {
      _createError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Advance status — optimistic update in list
  // ─────────────────────────────────────────────
  final Set<String> _advancingIds = {};
  bool isAdvancing(String copyId) => _advancingIds.contains(copyId);

  Future<bool> advanceStatus(CertifiedCopyModel copy) async {
    if (copy.status.next == null) return false;
    final newStatus = copy.status.next!.apiLabel;

    _advancingIds.add(copy.id);
    notifyListeners();

    try {
      final updated = await _courtPortalRepository.advanceStatus(
        copyId: copy.id,
        newStatus: newStatus,
      );
      // Replace in list
      _copies = _copies!.map((c) => c.id == copy.id ? updated : c).toList();
      return true;
    } catch (e) {
      _copiesError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _advancingIds.remove(copy.id);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Delete copy
  // ─────────────────────────────────────────────
  Future<bool> deleteCopy(String copyId) async {
    try {
      await _courtPortalRepository.deleteCopy(copyId);
      _copies = _copies!.where((c) => c.id != copyId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _copiesError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Initial load — called from screen initState
  // ─────────────────────────────────────────────
  Future<void> initialLoad() async {
    // Load both in parallel — both tabs visible on first open
    await Future.wait([loadRoster(), loadCopies()]);
  }

  Future<void> refresh() async {
    await Future.wait([refreshRoster(), loadCopies()]);
  }
}

// Extension to get the API string from CopyStatus
extension _CopyStatusApi on CopyStatus {
  String get apiLabel {
    switch (this) {
      case CopyStatus.applied:
        return 'applied';
      case CopyStatus.processing:
        return 'processing';
      case CopyStatus.ready:
        return 'ready';
    }
  }
}
