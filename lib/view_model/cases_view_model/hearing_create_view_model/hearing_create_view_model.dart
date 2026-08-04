import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_create_repository.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/legal_task_view_model.dart';

class HearingCreateViewModel with ChangeNotifier {
  final HearingCreateRepo _hearingCreateRepo = HearingCreateRepo();
  final TextEditingController hearingTitleController = TextEditingController();
  final TextEditingController hearingNotesController = TextEditingController();

  // Registration Date
  DateTime? _hearingDateTime;
  DateTime? get hearingDateTime => _hearingDateTime;

  // True only if the lawyer explicitly picked a time via setHearingTime.
  // Most hearings are cause-list date entries with no fixed clock time —
  // this stays false unless the lawyer opts in.
  bool _hasSpecificTime = false;
  bool get hasSpecificTime => _hasSpecificTime;

  void setHearingDateTime(DateTime? date) {
    if (date != null) {
      if (_hasSpecificTime && _hearingDateTime != null) {
        // A time was already picked — keep it when the date changes.
        _hearingDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _hearingDateTime!.hour,
          _hearingDateTime!.minute,
        );
      } else {
        _hearingDateTime = DateTime(date.year, date.month, date.day);
      }
    }
    notifyListeners();
  }

  /// Sets or clears the specific time-of-day for the currently selected
  /// date. Pass null to remove a previously set time and fall back to
  /// date-only (the backend will anchor it to the default court hour).
  void setHearingTime(TimeOfDay? time) {
    if (_hearingDateTime == null) return;

    _hasSpecificTime = time != null;
    _hearingDateTime = time != null
        ? DateTime(
            _hearingDateTime!.year,
            _hearingDateTime!.month,
            _hearingDateTime!.day,
            time.hour,
            time.minute,
          )
        : DateTime(
            _hearingDateTime!.year,
            _hearingDateTime!.month,
            _hearingDateTime!.day,
          );
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<HearingPublicModel> createHearing(
      BuildContext context, String caseId) async {
    final hearing = HearingCreateModel(
      title: hearingTitleController.text.trim(),
      hearingDateTime: _hearingDateTime ?? DateTime.now(),
      hasSpecificTime: _hasSpecificTime,
      notes: hearingNotesController.text.trim(),
    );

    try {
      setLoading(true);
      final dbHearing = await _hearingCreateRepo.createHearing(
        caseId: caseId,
        hearing: hearing,
      );
      context.read<LegalTaskViewModel>().createAutoTask(
            caseId: dbHearing.caseId,
            hearingId: dbHearing.id,
            hearingDateTime: dbHearing.hearingDateTime,
            caseTitle: dbHearing.title,
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
    _hasSpecificTime = false;
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
