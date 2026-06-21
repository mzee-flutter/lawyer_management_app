import 'package:flutter/foundation.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_archived_list_repo.dart';

class CaseArchivedListViewModel with ChangeNotifier {
  final CaseArchivedListRepo _caseArchivedListRepo = CaseArchivedListRepo();

  /// Pagination
  int _page = 1;
  final int _size = 10;

  /// Client list
  List<CaseModel> _archiveCaseList = [];
  List<CaseModel> get archiveCaseList => _archiveCaseList;

  /// Removing client by restoring
  void removeFromArchived(CaseModel caseData) {
    final index = _archiveCaseList.indexWhere((c) => c.id == caseData.id);
    if (index != -1) {
      _archiveCaseList.removeAt(index);
      notifyListeners();
    }
  }

  /// Loading flags
  bool isFirstLoading = false; // for initial page
  bool isMoreLoading = false; // for load more
  bool hasMore = true; // if backend still has more data

  Future<void> fetchArchivedCases({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (isMoreLoading || !hasMore) return;
      isMoreLoading = true;
    } else if (!isRefresh) {
      // reset state for first load
      _page = 1;
      hasMore = true;
      _archiveCaseList.clear();
      isFirstLoading = true;
    } else {
      _page = 1;
      hasMore = true;
    }
    notifyListeners();

    try {
      final cases = await _caseArchivedListRepo.fetchArchivedCases(
        page: _page,
        size: _size,
      );
      if (cases.isEmpty) {
        hasMore = false;
      }
      if (isRefresh) {
        _archiveCaseList.clear();
        _archiveCaseList = cases;
        _page = 2;
      } else if (loadMore) {
        _archiveCaseList.addAll(cases);
        _page++;
      } else {
        _archiveCaseList = cases;
        _page = 2;
      }
    } catch (e) {
      debugPrint("Error in CaseArchivedListViewModel: $e");
    } finally {
      if (loadMore) {
        isMoreLoading = false;
      } else {
        isFirstLoading = false;
      }
      notifyListeners();
    }
  }
}
