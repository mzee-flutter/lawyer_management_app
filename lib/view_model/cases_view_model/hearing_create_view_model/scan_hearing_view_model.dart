import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/scan_confirm_repo.dart';
import 'package:right_case/repository/case_repository/hearing_repository/scan_upload_repo.dart';

import '../../../models/case_models/scan_model.dart';

enum ScanStatus {
  idle,
  capturing,
  uploading,
  reviewing, // extraction succeeded, lawyer is on the confirmation form
  confirming,
  success,
  error,
  cancelled,
}

const Duration _kScanUploadTimeout = Duration(seconds: 45);

class ScanHearingViewModel with ChangeNotifier {
  final ScanUploadRepo _uploadRepo = ScanUploadRepo();
  final ScanConfirmRepo _confirmRepo = ScanConfirmRepo();
  final ImagePicker _picker = ImagePicker();

  ScanStatus _status = ScanStatus.idle;
  ScanStatus get status => _status;

  String? _error;
  String? get error => _error;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  File? _capturedImage;
  File? get capturedImage => _capturedImage;

  ScanExtractionModel? _extraction;
  ScanExtractionModel? get extraction => _extraction;

  // Editable fields on the confirmation screen — pre-filled from the
  // extraction, but the lawyer can change any of these before confirming.
  // Nothing gets scheduled from raw model output untouched.
  String? _selectedCaseId;
  String? get selectedCaseId => _selectedCaseId;

  DateTime? _hearingDate;
  DateTime? get hearingDate => _hearingDate;

  TimeOfDay? _hearingTime;
  TimeOfDay? get hearingTime => _hearingTime;
  bool get hasSpecificTime => _hearingTime != null;

  final TextEditingController notesController = TextEditingController();

  CancelToken? _cancelToken;
  bool _disposed = false;
  int _requestId = 0;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _setStatus(ScanStatus status) {
    if (_disposed) return;
    _status = status;
    _safeNotify();
  }

  /// All cases the lawyer could plausibly pick from on the confirmation
  /// screen — the matched case (if any) plus every candidate, deduplicated.
  List<ScanCaseCandidateModel> get selectableCases {
    final Map<String, ScanCaseCandidateModel> byId = {};
    final extraction = _extraction;
    if (extraction == null) return [];
    if (extraction.matchedCase != null) {
      byId[extraction.matchedCase!.caseId] = extraction.matchedCase!;
    }
    for (final c in extraction.candidateCases) {
      byId[c.caseId] = c;
    }
    return byId.values.toList();
  }

  /// Display title for whichever case is currently selected — falls back
  /// to the raw extracted title if the selection isn't one of the known
  /// candidates (shouldn't normally happen, but keeps this safe).
  String get selectedCaseDisplayTitle {
    final id = _selectedCaseId;
    if (id != null) {
      final match = selectableCases.where((c) => c.caseId == id);
      if (match.isNotEmpty) return match.first.displayTitle;
    }
    return _extraction?.extractedCaseTitle ?? 'this case';
  }

  void selectCase(String caseId) {
    _selectedCaseId = caseId;
    _safeNotify();
  }

  void setHearingDate(DateTime date) {
    _hearingDate = DateTime(date.year, date.month, date.day);
    _safeNotify();
  }

  void setHearingTime(TimeOfDay? time) {
    _hearingTime = time;
    _safeNotify();
  }

  /// STEP 1: Capture a photo from the camera. Cancelling the camera UI is
  /// not an error — just goes back to idle silently.
  Future<void> captureFromCamera() async {
    if (_status == ScanStatus.uploading || _status == ScanStatus.confirming) {
      return;
    }
    _setStatus(ScanStatus.capturing);
    _error = null;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) {
        _setStatus(ScanStatus.idle);
        return;
      }
      _capturedImage = File(picked.path);
      _safeNotify();
      await _uploadAndExtract();
    } catch (e) {
      _error = 'Could not open the camera: ${e.toString()}';
      _setStatus(ScanStatus.error);
    }
  }

  /// Retake — goes back to the camera without leaving the screen.
  Future<void> retake() async {
    _capturedImage = null;
    _extraction = null;
    _error = null;
    _setStatus(ScanStatus.idle);
    await captureFromCamera();
  }

  /// STEP 2: Cancellable, timeout-protected upload + extraction call.
  Future<void> _uploadAndExtract() async {
    if (_capturedImage == null) return;

    final int requestId = ++_requestId;
    _cancelToken = CancelToken();
    _error = null;
    _uploadProgress = 0.0;
    _setStatus(ScanStatus.uploading);

    try {
      final result = await _uploadRepo
          .extractFromImage(
            image: _capturedImage!,
            cancelToken: _cancelToken,
            onProgress: (sent, total) {
              if (requestId != _requestId || total <= 0) return;
              _uploadProgress = (sent / total).clamp(0.0, 1.0);
              _safeNotify();
            },
          )
          .timeout(_kScanUploadTimeout);

      if (requestId != _requestId) return; // superseded by a retake/cancel

      _extraction = result;
      _selectedCaseId = result.matchedCase?.caseId;
      _hearingDate = _parseExtractedDate(result.extractedHearingDate);
      _hearingTime = _parseExtractedTime(result.extractedHearingTime);
      notesController.text = '';
      _setStatus(ScanStatus.reviewing);
    } on TimeoutException {
      if (requestId != _requestId) return;
      _cancelToken?.cancel('Scan timed out');
      _error =
          'This is taking too long. Please check your connection and try again.';
      _setStatus(ScanStatus.error);
    } on DioException catch (e) {
      if (requestId != _requestId) return;
      if (e.type == DioExceptionType.cancel) {
        _setStatus(ScanStatus.cancelled);
        return;
      }
      final serverMessage = e.response?.data is Map
          ? (e.response?.data['detail']?.toString())
          : null;
      _error = serverMessage ??
          'Could not read the document: ${e.message ?? "connection error"}';
      _setStatus(ScanStatus.error);
    } catch (e) {
      if (requestId != _requestId) return;
      _error = 'Something went wrong reading this document. Please try again.';
      _setStatus(ScanStatus.error);
    } finally {
      if (requestId == _requestId) _cancelToken = null;
    }
  }

  DateTime? _parseExtractedDate(String? raw) {
    if (raw == null) return null;
    try {
      final parts = raw.split('-');
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseExtractedTime(String? raw) {
    if (raw == null) return null;
    try {
      final parts = raw.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  /// STEP 3: Lawyer taps Confirm — creates the actual hearing.
  /// Returns null (and sets `error`) if validation fails or the request
  /// errors out — the screen checks for null rather than catching here.
  Future<HearingPublicModel?> confirmAndCreateHearing() async {
    if (_extraction == null) return null;

    if (_selectedCaseId == null) {
      _error = 'Please select which case this hearing belongs to.';
      _setStatus(ScanStatus.error);
      return null;
    }
    if (_hearingDate == null) {
      _error = 'Please set the next hearing date.';
      _setStatus(ScanStatus.error);
      return null;
    }

    _setStatus(ScanStatus.confirming);
    try {
      final hearing = await _confirmRepo.confirmScan(
        scanId: _extraction!.scanId,
        caseId: _selectedCaseId!,
        hearingDate: _hearingDate!,
        hearingTime: _hearingTime,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
      _setStatus(ScanStatus.success);
      return hearing;
    } catch (e) {
      _error = 'Could not schedule the hearing. Please try again.';
      _setStatus(ScanStatus.error);
      return null;
    }
  }

  /// Discards the current scan on the server (marks it as not acted on)
  /// and resets the workflow so the lawyer can start over.
  Future<void> discardCurrentScan() async {
    final scanId = _extraction?.scanId;
    resetWorkflow();
    if (scanId != null) {
      try {
        await _confirmRepo.discardScan(scanId);
      } catch (_) {
        // Best-effort — the lawyer has already moved on locally either way.
      }
    }
  }

  /// Cancels any in-flight request and resets everything — safe to call at
  /// any time, including mid-upload.
  void resetWorkflow() {
    _requestId++;
    _cancelToken?.cancel('Cancelled by user');
    _cancelToken = null;
    _capturedImage = null;
    _extraction = null;
    _selectedCaseId = null;
    _hearingDate = null;
    _hearingTime = null;
    _uploadProgress = 0.0;
    _error = null;
    _status = ScanStatus.idle;
    _safeNotify();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('ViewModel disposed');
    notesController.dispose();
    _disposed = true;
    super.dispose();
  }
}
