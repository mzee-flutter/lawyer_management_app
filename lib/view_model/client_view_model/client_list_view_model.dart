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

  void _toggleLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void unFocusSearch() {
    searchFocusNode.unfocus();
  }

  List<ClientModel> _clientList = [];
  List<ClientModel> get filterClients {
    if (searchQuery.isEmpty) return _clientList;
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
    _clientList.add(client);
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

  Future<void> fetchClientList() async {
    _toggleLoading(true);
    try {
      final clients = await _clientListRepo.fetchClientList();
      _clientList = clients;
      _toggleLoading(false);
    } catch (e) {
      debugPrint("Error in ClientListViewModel: $e");
    } finally {
      _toggleLoading(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose(); // 👈 clean up
    super.dispose();
  }
}
