import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_archived_list_repo.dart';

class CaseArchivedListViewModel extends ChangeNotifier {
  final CaseArchivedListRepo _caseArchivedListRepo = CaseArchivedListRepo();

  /// Pagination
  int _page = 1;
  final int _size = 10;

  /// Case list
  List<CaseModel> _archiveCaseList = [];
  List<CaseModel> get archiveCaseList => _archiveCaseList;

  /// Removing case by restoring
  void removeFromArchived(CaseModel caseData) {
    final index = _archiveCaseList.indexWhere((c) => c.id == caseData.id);
    if (index != -1) {
      _archiveCaseList.removeAt(index);
      notifyListeners();
    }
  }

  /// Loading flags -- private with getters, same rationale as
  /// ClientArchivedListViewModel. Getter names unchanged externally.
  bool _isFirstLoading = false;
  bool get isFirstLoading => _isFirstLoading;

  bool _isMoreLoading = false;
  bool get isMoreLoading => _isMoreLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool get canLoadMore => _hasMore && !_isMoreLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> fetchArchivedCases({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (_isMoreLoading || !_hasMore) return;
      _errorMessage = null;
      _isMoreLoading = true;
    } else if (!isRefresh) {
      _page = 1;
      _hasMore = true;
      _archiveCaseList.clear();
      _errorMessage = null;
      _isFirstLoading = true;
    } else {
      _page = 1;
      _hasMore = true;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final cases = await _caseArchivedListRepo.fetchArchivedCases(
        page: _page,
        size: _size,
      );
      if (cases.length < _size) {
        _hasMore = false;
      }
      if (isRefresh) {
        _archiveCaseList = cases;
        _page = 2;
      } else if (loadMore) {
        _archiveCaseList.addAll(cases);
        _page++;
      } else {
        _archiveCaseList = cases;
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
      debugPrint('Error in CaseArchivedListViewModel: $e');
      debugPrint(stack.toString());
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      if (loadMore) {
        _isMoreLoading = false;
      } else {
        _isFirstLoading = false;
      }
      notifyListeners();
    }
  }
}
