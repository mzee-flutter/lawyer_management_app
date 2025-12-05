import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_stage_repo.dart';

class CaseStageViewModel with ChangeNotifier {
  final CaseStageRepo _caseStageRepo = CaseStageRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CaseStageModel> _caseStages = [];
  List<CaseStageModel> get items => _caseStages;

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
    if (_caseStages.isNotEmpty) return;
    try {
      _setLoading(true);

      final stages = await _caseStageRepo.fetchCaseStages();
      _caseStages = stages;
    } catch (e) {
      debugPrint("Error in CaseStageViewModel: $e");
    } finally {
      _setLoading(false);
    }
  }
}
