import 'package:flutter/material.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_list_repo.dart';

class ClientListViewModel extends ChangeNotifier {
  final ClientListRepo _clientListRepo = ClientListRepo();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

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

  List<ClientModel> _clientList = [];
  List<ClientModel> get filterClients {
    if (_searchQuery.isEmpty) return _clientList;
    return _clientList
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery))
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

  /// Fetch page 1 (loadMore=false) or next page (loadMore=true).
  Future<void> fetchClientList({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _setLoadingMore(true);
    } else {
      // initial load or refresh
      _page = 1;
      _hasMore = true;
      _clientList.clear();
      _setLoading(true);
    }

    try {
      final clients = await _clientListRepo.fetchClientList(
        page: _page,
        size: _size,
      );

      // If backend returned nothing, stop further calls
      if (clients.isEmpty) {
        _hasMore = false;
      } else {
        // append or set depending on loadMore
        if (loadMore) {
          _clientList.addAll(clients);
        } else {
          _clientList = clients;
        }
        _page++;
        // if returned fewer than page size, no more data
        if (clients.length < _size) _hasMore = false;
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

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
