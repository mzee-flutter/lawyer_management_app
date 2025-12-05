import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_status_repo.dart';

class CaseStatusViewModel with ChangeNotifier {
  final CaseStatusRepo _caseStatusRepo = CaseStatusRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CaseStatusModel> _caseStatuses = [];
  List<CaseStatusModel> get items => _caseStatuses;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? selectedId;
  String? selectedName;

  void selectItem(String id, String name) {
    selectedId = id;
    selectedName = name;
    notifyListeners();
  }

  Future<void> fetchItems() async {
    if (_caseStatuses.isNotEmpty) return;
    try {
      _setLoading(true);

      final statuses = await _caseStatusRepo.fetchCaseStatuses();
      _caseStatuses = statuses;
    } catch (e) {
      debugPrint("Error in CaseStatusViewModel: $e");
    } finally {
      _setLoading(false);
    }
  }
}
