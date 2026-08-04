// lib/view_model/cases_view_model/hearing_create_view_model/hearing_update_view_model.dart

import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_update_repo.dart';

class HearingUpdateViewModel with ChangeNotifier {
  final HearingUpdateRepo _repo = HearingUpdateRepo();

  // ── Text controllers ─────────────────────────────────────
  final TextEditingController hearingTitleController = TextEditingController();
  final TextEditingController hearingNotesController = TextEditingController();
  final TextEditingController adjournmentReasonController =
      TextEditingController();

  // ── State ─────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _hearingDateTime;
  DateTime? get hearingDateTime => _hearingDateTime;

  String _selectedStatus = 'scheduled';
  String get selectedStatus => _selectedStatus;

  // True when the status dropdown is set to "adjourned"
  // Drives the animated adjournment reason field visibility
  bool get isAdjourning => _selectedStatus == 'adjourned';

  // ── Status options ────────────────────────────────────────
  final List<String> statuses = [
    'scheduled',
    'completed',
    'adjourned',
    'cancelled',
  ];

  // ── Initialise all fields from an existing hearing ───────
  void initializeHearingField(HearingPublicModel hearing) {
    _hearingDateTime = hearing.hearingDateTime;
    hearingTitleController.text = hearing.title;
    hearingNotesController.text = hearing.notes ?? '';
    _selectedStatus = hearing.status;

    // Pre-populate adjournment reason if already set
    adjournmentReasonController.text = hearing.adjournmentReason ?? '';

    notifyListeners();
  }

  void setHearingDateTime(DateTime date) {
    _hearingDateTime = date;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    // Clear adjournment reason when switching away from adjourned
    if (status != 'adjourned') {
      adjournmentReasonController.clear();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ── Update hearing ────────────────────────────────────────
  Future<HearingPublicModel> updateHearing(String hearingId) async {
    final payload = HearingUpdateModel(
      title: hearingTitleController.text.trim(),
      hearingDateTime: _hearingDateTime,
      notes: hearingNotesController.text.trim().isEmpty
          ? null
          : hearingNotesController.text.trim(),
      status: _selectedStatus,
      // Only send adjournment reason when actually adjourning
      adjournmentReason:
          isAdjourning && adjournmentReasonController.text.trim().isNotEmpty
              ? adjournmentReasonController.text.trim()
              : null,
      // adjournmentDate left null — backend auto-stamps today
    );

    _setLoading(true);
    try {
      return await _repo.updateHearing(payload, hearingId);
    } catch (e) {
      debugPrint('Error in HearingUpdateViewModel: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void resetFields() {
    _hearingDateTime = null;
    _selectedStatus = 'scheduled';
    hearingTitleController.clear();
    hearingNotesController.clear();
    adjournmentReasonController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    hearingTitleController.dispose();
    hearingNotesController.dispose();
    adjournmentReasonController.dispose();
    super.dispose();
  }
}
