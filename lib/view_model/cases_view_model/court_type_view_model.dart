import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';

import 'package:right_case/repository/case_repository/court_type_repo.dart';

class CourtTypeViewModel with ChangeNotifier {
  final CourtTypeRepo _courtTypeRepo = CourtTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CourtCategoryModel> _courtType = [];
  List<CourtCategoryModel> get items => _courtType;

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

///Today we have just done the repo and view models for all the dropdown fields...
///i just have to just wire up the view models with UI
///and also register all the view models in the main files
