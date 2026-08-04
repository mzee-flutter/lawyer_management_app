import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/court_type_repo.dart';

class CourtTypeViewModel with ChangeNotifier {
  final CourtTypeRepo _courtTypeRepo = CourtTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CourtCategoryModel> _courtType = [];
  List<CourtCategoryModel> get courtType => _courtType;

  String? selectedCourtId;
  String? selectedCourtName;
  String? selectedSubCourtId;
  String? selectedSubCourtName;
  String? selectedSubSubCourtId;
  String? selectedSubSubCourtName;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // ── Safe null-returning find (no external package needed) ──────────
  CourtCategoryModel? _findInList(
      List<CourtCategoryModel>? list, bool Function(CourtCategoryModel) test) {
    if (list == null) return null;
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }

  // ── Layer 1: user taps a root court ───────────────────────────────
  void selectCourtType(String id, String name) {
    selectedCourtId = id;
    selectedCourtName = name;
    selectedSubCourtId = null;
    selectedSubCourtName = null;
    selectedSubSubCourtId = null;
    selectedSubSubCourtName = null;
    notifyListeners();
  }

  // ── Layer 1: edit-mode preselect by id ────────────────────────────
  void selectCourtById(String? id) {
    if (id == null) return;
    final court = _findInList(_courtType, (e) => e.id == id);
    if (court != null) {
      selectedCourtId = court.id;
      selectedCourtName = court.name;
      notifyListeners();
    }
  }

  // ── Layer 2: edit-mode preselect sub-category ─────────────────────
  void selectSubCategoryById(String? subId) {
    if (subId == null) return;
    for (final court in _courtType) {
      final sub = _findInList(court.subcategories, (s) => s.id == subId);
      if (sub != null) {
        selectedCourtId = court.id;
        selectedCourtName = court.name;
        selectedSubCourtId = sub.id;
        selectedSubCourtName = sub.name;
        selectedSubSubCourtId = null;
        selectedSubSubCourtName = null;
        notifyListeners();
        return;
      }
    }
  }

  // ── Layer 3: edit-mode preselect sub-sub-category ─────────────────
  // FIX: was using firstWhereOrNull on sub.subcategories → crash.
  // Now uses a plain for-loop — no package dependency at all.
  void selectSubSubCategoryById(String? id) {
    if (id == null) return;
    for (final court in _courtType) {
      for (final sub in court.subcategories ?? []) {
        for (final subSub in sub.subcategories ?? []) {
          if (subSub.id == id) {
            selectedCourtId = court.id;
            selectedCourtName = court.name;
            selectedSubCourtId = sub.id;
            selectedSubCourtName = sub.name;
            selectedSubSubCourtId = subSub.id;
            selectedSubSubCourtName = subSub.name;
            notifyListeners();
            return;
          }
        }
      }
    }
    debugPrint(
        '[CourtTypeViewModel] selectSubSubCategoryById: id "$id" not found in tree');
  }

  /// Single entry-point for edit-mode preselection.
  /// Searches layer 3 → layer 2 → layer 1 in order.
  /// Caller never needs to know the depth.
  void autoSelectById(String? id) {
    if (id == null) return;

    // ── Layer 3 ──────────────────────────────────────────────────────
    for (final court in _courtType) {
      for (final sub in court.subcategories ?? []) {
        for (final subSub in sub.subcategories ?? []) {
          if (subSub.id == id) {
            selectedCourtId = court.id;
            selectedCourtName = court.name;
            selectedSubCourtId = sub.id;
            selectedSubCourtName = sub.name;
            selectedSubSubCourtId = subSub.id;
            selectedSubSubCourtName = subSub.name;
            notifyListeners();
            return;
          }
        }
      }
    }

    // ── Layer 2 ──────────────────────────────────────────────────────
    for (final court in _courtType) {
      for (final sub in court.subcategories ?? []) {
        if (sub.id == id) {
          selectedCourtId = court.id;
          selectedCourtName = court.name;
          selectedSubCourtId = sub.id;
          selectedSubCourtName = sub.name;
          selectedSubSubCourtId = null;
          selectedSubSubCourtName = null;
          notifyListeners();
          return;
        }
      }
    }

    // ── Layer 1 ──────────────────────────────────────────────────────
    for (final court in _courtType) {
      if (court.id == id) {
        selectedCourtId = court.id;
        selectedCourtName = court.name;
        selectedSubCourtId = null;
        selectedSubCourtName = null;
        selectedSubSubCourtId = null;
        selectedSubSubCourtName = null;
        notifyListeners();
        return;
      }
    }

    debugPrint('[CourtTypeViewModel] autoSelectById: "$id" not found in tree');
  }

  // ── Layer 2: user taps a sub-court in the overlay ─────────────────
  void selectSubCourtType(String subId, String subName) {
    selectedSubCourtId = subId;
    selectedSubCourtName = subName;
    selectedSubSubCourtId = null;
    selectedSubSubCourtName = null;
    notifyListeners();
  }

  // ── Utility: find the root parent of any sub node ─────────────────
  CourtCategoryModel? findParentOfSub(String subId) {
    for (final court in _courtType) {
      for (final sub in court.subcategories ?? []) {
        if (sub.id == subId) return court;
      }
    }
    return null;
  }

  // ── Fetch (cached after first load) ───────────────────────────────
  Future<void> fetchCourtType() async {
    if (_courtType.isNotEmpty) return;
    try {
      _setLoading(true);
      _courtType = await _courtTypeRepo.fetchCourtTypes();
    } catch (e) {
      debugPrint('[CourtTypeViewModel] fetchCourtType error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Hard reset ────────────────────────────────────────────────────
  void reset() {
    selectedCourtId = null;
    selectedCourtName = null;
    selectedSubCourtId = null;
    selectedSubCourtName = null;
    selectedSubSubCourtId = null;
    selectedSubSubCourtName = null;
    notifyListeners();
  }
}
