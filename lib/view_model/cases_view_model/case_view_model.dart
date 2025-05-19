import 'package:flutter/material.dart';
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
    Hive.box<CaseModel>('cases').listenable().addListener(_applyFilter);
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
    notifyListeners();
  }

  void _applyFilter() {
    final box = Hive.box<CaseModel>('cases');
    final allCases = box.values.toList();

    allCases.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_searchQuery.isEmpty) {
      _filteredCases = allCases;
    } else {
      _filteredCases = allCases.where((clientCase) {
        return clientCase.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            clientCase.clientId.contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  // --------------------- CASE CATEGORIES ----------------------

  List<CaseModel> get todayCases {
    final now = DateTime.now();
    return _filteredCases.where((caseModel) {
      return _isSameDate(caseModel.createdAt, now);
    }).toList();
  }

  List<CaseModel> get tomorrowCases {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return _filteredCases.where((caseModel) {
      return _isSameDate(caseModel.createdAt, tomorrow);
    }).toList();
  }

  List<CaseModel> get runningCases {
    return _filteredCases
        .where((caseModel) => caseModel.status == "Running")
        .toList();
  }

  List<CaseModel> get decidedCases {
    return _filteredCases
        .where((caseModel) => caseModel.status == "Decided")
        .toList();
  }

  List<CaseModel> get dateAwaitedCases {
    return _filteredCases
        .where((caseModel) => caseModel.status == "Date Awaited")
        .toList();
  }

  List<CaseModel> get abandonedCases {
    return _filteredCases
        .where((caseModel) => caseModel.status == "Abandoned")
        .toList();
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
