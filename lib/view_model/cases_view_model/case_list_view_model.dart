import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/cases_list_repo.dart';

class CaseListViewModel extends ChangeNotifier {
  final CasesListRepo _casesListRepo = CasesListRepo();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool _showSearch = false;
  bool get showSearch => _showSearch;

  void toggleShowSearch() {
    _showSearch = !showSearch;
    notifyListeners();
  }

  bool _isButtonIsVisible = true;
  bool get isButtonIsVisible => _isButtonIsVisible;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool get canLoadMore => _hasMore && !_isLoadingMore;

  /// Non-null only when the most recent fetch failed. See
  /// ClientListViewModel for the full rationale.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  int _page = 1;
  final int _size = 10;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setLoadingMore(bool val) {
    _isLoadingMore = val;
    notifyListeners();
  }

  void unFocusSearch() {
    searchFocusNode.unfocus();
  }

  List<CaseModel> _caseList = [];
  List<CaseModel> get filterCases {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _caseList;
    return _caseList
        .where((c) =>
            c.caseNumber.toLowerCase().contains(q) ||
            c.firstPartyName.toLowerCase().contains(q) ||
            (c.oppositePartyName ?? '').toLowerCase().contains(q) ||
            (c.courtName ?? '').toLowerCase().contains(q))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setClients(List<CaseModel> cases) {
    _caseList = cases;
    notifyListeners();
  }

  CaseModel? getCaseById(String caseId) {
    return _caseList.where((c) => c.id == caseId).firstOrNull;
  }

  void addCase(CaseModel caseData) {
    _caseList.insert(0, caseData);
    notifyListeners();
  }

  void updateCase(CaseModel dbCase) {
    final index = _caseList.indexWhere((c) => c.id == dbCase.id);
    if (index != -1) {
      _caseList[index] = dbCase;
      notifyListeners();
    }
  }

  void removeCase(CaseModel archiveCase) {
    final index = _caseList.indexWhere((c) => c.id == archiveCase.id);
    if (index != -1) {
      _caseList.removeAt(index);
      notifyListeners();
    }
  }

  /// Used for the upward syncing of files.
  void updateCaseFiles({
    required String caseId,
    required List<CaseFileModel> files,
  }) {
    final index = _caseList.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      _caseList[index] = _caseList[index].copyWith(files: files);
      notifyListeners();
    }
  }

  /// Used for the upward syncing of relatedClients.
  void updateRelatedClients({
    required String caseId,
    required List<RelatedClientModel> relatedClients,
  }) {
    final index = _caseList.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      _caseList[index] = _caseList[index].copyWith(
        relatedClients: relatedClients,
      );
      notifyListeners();
    }
  }

  /// Fetch page 1 (loadMore=false) or next page (loadMore=true).
  /// See ClientListViewModel.fetchClientList for the error-handling
  /// rationale -- same asymmetry applies: a loadMore failure never clears
  /// already-loaded cases.
  Future<void> fetchCaseList({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _errorMessage = null;
      _setLoadingMore(true);
    } else if (!isRefresh) {
      _page = 1;
      _hasMore = true;
      _caseList.clear();
      _errorMessage = null;
      _setLoading(true);
    } else {
      _page = 1;
      _hasMore = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final cases = await _casesListRepo.fetchCaseList(
        page: _page,
        size: _size,
      );

      if (cases.length < _size) {
        _hasMore = false;
      }
      if (loadMore) {
        _caseList.addAll(cases);
        _page++;
      } else {
        // Covers both plain initial load and isRefresh -- no need to
        // clear-then-reassign, a straight replace does the same thing.
        _caseList = cases;
        _page = 2;
      }
      _errorMessage = null;
    } on SocketException {
      _errorMessage =
          'No internet connection. Please check your network and try again.';
    } on TimeoutException {
      _errorMessage = 'The request timed out. Please try again.';
    } on ApiException catch (e) {
      _errorMessage = e.message.isNotEmpty
          ? e.message
          : 'Something went wrong. Please try again.';
    } catch (e, stack) {
      debugPrint('Error in CaseListViewModel.fetchCaseList: $e');
      debugPrint(stack.toString());
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      if (loadMore) {
        _setLoadingMore(false);
      } else {
        _setLoading(false);
      }
    }
  }

  void handleScroll(ScrollDirection direction) {
    final bool shouldBeVisible = direction == ScrollDirection.forward;

    if (_isButtonIsVisible != shouldBeVisible) {
      _isButtonIsVisible = shouldBeVisible;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
