import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_type_repo.dart';

class CaseTypeViewModel with ChangeNotifier {
  final CaseTypeRepo _caseTypeRepo = CaseTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  VoidCallback? onLoadedCallback;

  List<CaseTypeModel> _caseTypes = [];
  List<CaseTypeModel> get caseTypes => _caseTypes;

  /// Set loading true/false
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Fetch Case Types from API
  Future<void> fetchCaseTypes() async {
    try {
      _setLoading(true);

      final types = await _caseTypeRepo.fetchCaseTypes();
      _caseTypes = types;
    } catch (e) {
      debugPrint("Error in CaseTypeViewModel: $e");
    } finally {
      _setLoading(false);
      if (onLoadedCallback != null) {
        onLoadedCallback!();
      }
    }
  }
}
