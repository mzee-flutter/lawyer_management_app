import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:right_case/models/client_model.dart';

class ClientViewModel extends ChangeNotifier {
  String _searchQuery = '';
  List<ClientModel> _filteredClients = [];

  List<ClientModel> get filteredClients => _filteredClients;
  String get searchQuery => _searchQuery;

  ClientViewModel() {
    _init();
  }

  void _init() {
    Hive.box<ClientModel>('clients').listenable().addListener(_applyFilter);
    _applyFilter();
  }

  Future<void> addClient(ClientModel client) async {
    final box = Hive.box<ClientModel>('clients');
    await box.put(client.id, client);
  }

  void removeClient(ClientModel client) {
    client.delete();
  }

  void updateClient(ClientModel updatedClient) {
    final box = Hive.box<ClientModel>('clients');
    box.put(updatedClient.id, updatedClient);
  }

  void _applyFilter() {
    final box = Hive.box<ClientModel>('clients');
    final allClients = box.values.toList();

    allClients.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    if (_searchQuery.isEmpty) {
      _filteredClients = allClients;
    } else {
      _filteredClients = allClients.where((client) {
        return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            client.mobileNumber?.contains(_searchQuery) == true;
      }).toList();
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }
}
