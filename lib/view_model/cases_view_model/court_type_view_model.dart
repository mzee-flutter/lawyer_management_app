import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';

import 'package:right_case/repository/case_repository/court_type_repo.dart';

class CourtTypeViewModel with ChangeNotifier {
  final CourtTypeRepo _courtTypeRepo = CourtTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CourtCategoryModel> _courtType = [];
  List<CourtCategoryModel> get courtType => _courtType;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? selectedCourtId;
  String? selectedCourtName;
  String? selectedSubCourtId;
  String? selectedSubCourtName;

  void selectCourtType(String id, String name) {
    selectedCourtId = id;
    selectedCourtName = name;
    selectedSubCourtName = null;
    notifyListeners();
  }

  void selectSubCourtType(String subId, String subName) {
    selectedSubCourtId = subId;
    selectedSubCourtName = subName;
    notifyListeners();
  }

  Future<void> fetchCourtType() async {
    if (_courtType.isNotEmpty) return;
    try {
      _setLoading(true);

      final courts = await _courtTypeRepo.fetchCourtTypes();
      _courtType = courts;
    } catch (e) {
      debugPrint("Error in CourtTypeViewModel: $e");
    } finally {
      _setLoading(false);
    }
  }
}
