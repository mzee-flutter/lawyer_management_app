import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_list_repo.dart';

class ClientListViewModel extends ChangeNotifier {
  final ClientListRepo _clientListRepo = ClientListRepo();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  ClientListViewModel() {
    searchController.addListener(_syncSearchQuery);
  }

  void _syncSearchQuery() {
    final text = searchController.text.trim();
    if (text != _searchQuery) {
      _searchQuery = text;
      notifyListeners();
    }
  }

  /// Clears search state WITHOUT notifying listeners. Use this instead of
  /// `searchController.clear()` from any call site that can't safely
  /// trigger a rebuild -- most notably a View's dispose(). During
  /// widget-tree teardown the framework is locked, and clear()'s automatic
  /// listener callback (_syncSearchQuery -> notifyListeners) throws
  /// "setState() or markNeedsBuild() called when widget tree was locked."
  /// Removing the listener before mutating, then reattaching it, avoids
  /// that entirely while keeping live in-screen clears (e.g. tapping the
  /// search-close icon) working normally through the listener as before.
  void clearSearchSilently() {
    searchController.removeListener(_syncSearchQuery);
    searchController.clear();
    _searchQuery = '';
    searchController.addListener(_syncSearchQuery);
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

  List<ClientModel> _clientList = [];
  List<ClientModel> get filterClients {
    if (_searchQuery.isEmpty) return _clientList;
    final q = _searchQuery.toLowerCase();
    return _clientList
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(_searchQuery) ||
            c.cnic.contains(_searchQuery) ||
            c.email.toLowerCase().contains(q))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setClients(List<ClientModel> clients) {
    _clientList = clients;
    notifyListeners();
  }

  void addClient(ClientModel client) {
    _clientList.insert(0, client);
    notifyListeners();
  }

  void updateClient(ClientModel updateClient) {
    final index = _clientList.indexWhere((c) => c.id == updateClient.id);
    if (index != -1) {
      _clientList[index] = updateClient;
      notifyListeners();
    }
  }

  void removeClient(ClientModel archiveClient) {
    final index = _clientList.indexWhere((c) => c.id == archiveClient.id);
    if (index != -1) {
      _clientList.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> fetchClientList({
    bool loadMore = false,
    bool isRefresh = false,
  }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _errorMessage = null;
      _setLoadingMore(true);
    } else {
      _page = 1;
      _hasMore = true;
      _errorMessage = null;
      if (!isRefresh) {
        _clientList.clear();
        _setLoading(true);
      } else {
        notifyListeners();
      }
    }

    try {
      final clients = await _clientListRepo.fetchClientList(
        page: _page,
        size: _size,
      );

      if (clients.length < _size) {
        _hasMore = false;
      }

      if (loadMore) {
        _clientList.addAll(clients);
        _page++;
      } else {
        _clientList = clients;
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
      debugPrint('Error in ClientListViewModel.fetchClientList: $e');
      debugPrint(stack.toString());
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      loadMore ? _setLoadingMore(false) : _setLoading(false);
    }
  }

  Future<void> refresh() => fetchClientList(isRefresh: true);

  void handleScroll(ScrollDirection direction) {
    final bool shouldBeVisible = direction == ScrollDirection.forward;

    if (_isButtonIsVisible != shouldBeVisible) {
      _isButtonIsVisible = shouldBeVisible;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_syncSearchQuery);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
