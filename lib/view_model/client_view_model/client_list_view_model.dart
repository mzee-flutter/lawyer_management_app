import 'package:flutter/material.dart';
import 'package:right_case/models/client_models/client_create_model.dart';

import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_list_repo.dart';

class ClientListViewModel extends ChangeNotifier {
  final ClientListRepo _clientListRepo = ClientListRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _toggleLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<ClientModel> _clientList = [];
  List<ClientModel> get clientList => _clientList;

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

  void archiveClient(ClientModel archiveClient) {
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
}
