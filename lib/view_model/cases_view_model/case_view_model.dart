import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/case_model.dart';

class CaseViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<CaseModel> _filteredCases = [];

  List<CaseModel> get filteredCase => _filteredCases;

  CaseViewModel() {
    _init();
  }

  void _init() {
    Hive.box<CaseModel>('Cases').listenable().addListener(_applyFilter);
    _applyFilter();
  }

  void addCase(CaseModel clientCase) {
    final box = Hive.box<CaseModel>('cases');
    box.put(clientCase.id, clientCase);
    notifyListeners();
  }

  void removeCase(CaseModel clientCase) {
    clientCase.delete();
    notifyListeners();
  }

  void updateCase(CaseModel clientCase) {
    final box = Hive.box<CaseModel>('cases');
    box.put(clientCase.id, clientCase);
  }

  void _applyFilter() {
    final box = Hive.box<CaseModel>('cases');
    final allCases = box.values.toList();

    allCases.sort((a, b) {
      final aData = a.createdAt;
      final bData = b.createdAt;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (_searchQuery.isEmpty) {
      _filteredCases = allCases;
    }
    _filteredCases = allCases.where((clientCase) {
      return clientCase.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          clientCase.clientId.contains(_searchQuery) == true;
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
