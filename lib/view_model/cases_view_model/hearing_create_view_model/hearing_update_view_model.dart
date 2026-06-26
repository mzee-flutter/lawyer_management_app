import 'package:flutter/cupertino.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_update_repo.dart';

class HearingUpdateViewModel with ChangeNotifier {
  final HearingUpdateRepo _hearingUpdateRepo = HearingUpdateRepo();
  final TextEditingController hearingTitleController = TextEditingController();
  final TextEditingController hearingNotesController = TextEditingController();
  final TextEditingController hearingStatusController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  DateTime? _hearingDateTime;
  DateTime? get hearingDateTime => _hearingDateTime;

  bool get isPast => _hearingDateTime!.isBefore(DateTime.now().toUtc());

  void loadHearingStatus(HearingPublicModel hearing) {
    hearingStatusController.text = hearing.status;
  }

  void setHearingDateTime(DateTime date) {
    _hearingDateTime = date;
    notifyListeners();
  }

  void initializeHearingField(HearingPublicModel hearingData) {
    _hearingDateTime = hearingData.hearingDateTime;
    hearingTitleController.text = hearingData.title;
    hearingNotesController.text = hearingData.notes!;
    hearingStatusController.text = hearingData.status;
  }

  Future<HearingPublicModel> updateHearing(String hearingId) async {
    final hearing = HearingCreateModel(
      title: hearingTitleController.text.trim(),
      hearingDateTime: _hearingDateTime ?? DateTime.now(),
      notes: hearingNotesController.text.trim(),
      status: hearingStatusController.text.trim(),
    );
    toggleLoading(true);

    try {
      final dbHearing = await _hearingUpdateRepo.updateHearing(
        hearing,
        hearingId,
      );
      return dbHearing;
    } catch (e) {
      debugPrint("Error in HearingUpdateViewModel: $e");
      rethrow;
    } finally {
      toggleLoading(false);
    }
  }

  void resetFields() {
    hearingTitleController.clear();
    hearingNotesController.clear();
    hearingStatusController.clear();
    _hearingDateTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    hearingTitleController.dispose();
    hearingNotesController.dispose();
    hearingStatusController.dispose();
    super.dispose();
  }

  final List<String> statuses = [
    "scheduled",
    "completed",
    "adjourned",
    "cancelled",
  ];
}
