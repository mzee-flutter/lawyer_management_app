import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_archived_list_repo.dart';

class ClientArchivedListViewModel extends ChangeNotifier {
  final ClientArchivedListRepo _clientArchivedListRepo =
      ClientArchivedListRepo();

  /// Pagination
  int _page = 1;
  final int _size = 10;

  /// Client list
  List<ClientModel> _archiveClientList = [];
  List<ClientModel> get archiveClientList => _archiveClientList;

  /// Removing client by restoring
  void removeFromArchived(ClientModel client) {
    final index = _archiveClientList.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _archiveClientList.removeAt(index);
      notifyListeners();
    }
  }

  /// Loading flags -- now private with public getters. Previously these
  /// were bare public fields, meaning any holder of the ViewModel could
  /// mutate them directly and desync UI state from what's actually
  /// happening in fetchArchivedClients. Getter names are unchanged so
  /// nothing reading vm.isFirstLoading / vm.isMoreLoading elsewhere breaks.
  bool _isFirstLoading = false;
  bool get isFirstLoading => _isFirstLoading;

  bool _isMoreLoading = false;
  bool get isMoreLoading => _isMoreLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool get canLoadMore => _hasMore && !_isMoreLoading;

  /// Non-null only when the most recent fetch failed. An empty list with no
  /// error means "genuinely nothing archived." An empty list WITH an error
  /// means the request failed and we don't actually know what's out there.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> fetchArchivedClients({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (_isMoreLoading || !_hasMore) return;
      _errorMessage = null;
      _isMoreLoading = true;
    } else if (!isRefresh) {
      // reset state for first load
      _page = 1;
      _hasMore = true;
      _archiveClientList.clear();
      _errorMessage = null;
      _isFirstLoading = true;
    } else {
      _page = 1;
      _hasMore = true;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final clients = await _clientArchivedListRepo.fetchArchivedClients(
        page: _page,
        size: _size,
      );
      if (clients.length < _size) {
        _hasMore = false;
      }
      if (isRefresh) {
        _archiveClientList = clients;
        _page = 2;
      } else if (loadMore) {
        _archiveClientList.addAll(clients);
        _page++;
      } else {
        _archiveClientList = clients;
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
      debugPrint('Error in ClientArchivedListViewModel: $e');
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
