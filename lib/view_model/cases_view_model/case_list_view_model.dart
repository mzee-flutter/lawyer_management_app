import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:right_case/models/case_models/case_model.dart';

import 'package:right_case/repository/case_repository/cases_list_repo.dart';

class CaseListViewModel extends ChangeNotifier {
  final CasesListRepo _casesListRepo = CasesListRepo();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

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
    if (_searchQuery.isEmpty) return _caseList;
    return _caseList
        .where((c) =>
            c.courtName!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.judgeName!.contains(_searchQuery))
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

  /// This method is use for the upward syncing of files
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

  /// This method is use for the upward syncing of relatedClients
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
  Future<void> fetchCaseList({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _setLoadingMore(true);
    } else if (!isRefresh) {
      /// initial load or refresh
      _page = 1;
      _hasMore = true;
      _caseList.clear();
      _setLoading(true);
    } else {
      _page = 1;
      _hasMore = true;
    }

    try {
      final cases = await _casesListRepo.fetchCaseList(
        page: _page,
        size: _size,
      );

      /// If backend returned nothing, stop further calls
      if (cases.length < _size) {
        _hasMore = false;
      }
      if (isRefresh) {
        _caseList.clear();
        _caseList = cases;
        _page = 2;
      } else if (loadMore) {
        _caseList.addAll(cases);
        _page++;
      } else {
        _caseList = cases;
        _page = 2;
      }
    } catch (e) {
      debugPrint("Error in ClientListViewModel: $e");
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
