import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/court_type_repo.dart';

class CourtTypeViewModel with ChangeNotifier {
  final CourtTypeRepo _courtTypeRepo = CourtTypeRepo();

  bool _loading = false;
  bool get loading => _loading;

  List<CourtCategoryModel> _courtType = [];
  List<CourtCategoryModel> get courtType => _courtType;

  /// Selected values
  String? selectedCourtId;
  String? selectedCourtName;
  String? selectedSubCourtId;
  String? selectedSubCourtName;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // ===============================
  // USER selects parent court
  // ===============================
  void selectCourtType(String id, String name) {
    selectedCourtId = id;
    selectedCourtName = name;

    // reset subcategory ONLY on user change
    selectedSubCourtId = null;
    selectedSubCourtName = null;

    notifyListeners();
  }

  // ===============================
  // USER selects sub court
  // ===============================
  void selectSubCourtType(String subId, String subName) {
    selectedSubCourtId = subId;
    selectedSubCourtName = subName;
    notifyListeners();
  }

  // ===============================
  // EDIT MODE: preselect parent
  // ===============================
  void selectCourtById(String? id) {
    if (id == null) return;

    final court = _courtType.firstWhereOrNull((e) => e.id == id);
    if (court != null) {
      selectedCourtId = court.id;
      selectedCourtName = court.name;
      notifyListeners();
    }
  }

  // ===============================
  // EDIT MODE: preselect sub court
  // ===============================
  void selectSubCategoryById(String? subId) {
    if (subId == null) return;

    for (final court in _courtType) {
      final sub = court.subcategories?.firstWhereOrNull((s) => s.id == subId);

      if (sub != null) {
        selectedCourtId = court.id;
        selectedCourtName = court.name;

        selectedSubCourtId = sub.id;
        selectedSubCourtName = sub.name;

        notifyListeners();
        return;
      }
    }
  }

  CourtCategoryModel? findParentOfSub(String subId) {
    for (final court in _courtType) {
      final subs = court.subcategories ?? [];
      for (final sub in subs) {
        if (sub.id == subId) {
          return court;
        }
      }
    }
    return null;
  }

  // ===============================
  // Fetch courts
  // ===============================
  Future<void> fetchCourtType() async {
    if (_courtType.isNotEmpty) return;

    try {
      _setLoading(true);
      _courtType = await _courtTypeRepo.fetchCourtTypes();
    } catch (e) {
      debugPrint("Error in CourtTypeViewModel: $e");
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    selectedCourtId = null;
    selectedSubCourtId = null;
    notifyListeners();
  }
}
