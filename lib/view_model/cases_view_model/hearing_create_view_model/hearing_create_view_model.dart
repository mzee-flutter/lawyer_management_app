import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_create_repository.dart';

class HearingCreateViewModel with ChangeNotifier {
  final HearingCreateRepo _hearingCreateRepo = HearingCreateRepo();
  final TextEditingController hearingTitleController = TextEditingController();
  final TextEditingController hearingNotesController = TextEditingController();

  // Registration Date
  DateTime? _hearingDateTime;
  DateTime? get hearingDateTime => _hearingDateTime;

  void setHearingDateTime(DateTime? date) {
    if (date != null) {
      _hearingDateTime = date;
    }
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<HearingPublicModel> createHearing(String caseId) async {
    final hearing = HearingCreateModel(
      title: hearingTitleController.text.trim(),
      hearingDateTime: _hearingDateTime ?? DateTime.now(),
      notes: hearingNotesController.text.trim(),
    );

    try {
      setLoading(true);
      final dbHearing = await _hearingCreateRepo.createHearing(
        caseId: caseId,
        hearing: hearing,
      );

      return dbHearing;
    } catch (e) {
      debugPrint("Error in HearingCreateViewModel: ${e.toString()}");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void resetFields() {
    _hearingDateTime = null;
    hearingTitleController.clear();
    hearingNotesController.clear();
  }

  @override
  void dispose() {
    hearingTitleController.dispose();
    hearingNotesController.dispose();
    super.dispose();
  }
}
