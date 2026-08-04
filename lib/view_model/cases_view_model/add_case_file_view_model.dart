import 'dart:async';
import 'dart:io';

// NOTE: this fix assumes Dio, inferred from the onProgress(sent, total)
// signature in your original code (that shape matches Dio's onSendProgress).
// If you're on a different HTTP client, keep everything below except the
// CancelToken import/type — tell me which client and I'll adapt that part.
import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/add_case_file_repo.dart';

enum UploadStatus {
  idle,
  picking,
  readyToUpload,
  uploading,
  success,
  error,
  cancelled,
}

class UploadFileItem {
  /// Stable identity independent of list order/index.
  final String id;
  final File file;
  final String fileName;
  final int fileSize;
  double progress;
  String? itemError;

  UploadFileItem({
    required this.id,
    required this.file,
    required this.fileName,
    required this.fileSize,
    this.progress = 0.0,
    this.itemError,
  });
}

/// Hard safety net: if the server never responds after the request body is
/// fully sent (the exact "stuck at 100%" failure mode you saw), this forces
/// the upload to fail cleanly instead of hanging forever.
const Duration _kUploadTimeout = Duration(seconds: 45);

class AddCaseFileViewModel with ChangeNotifier {
  final AddCaseFileRepo _repo = AddCaseFileRepo();

  UploadStatus _status = UploadStatus.idle;
  UploadStatus get status => _status;

  String? _error;
  String? get error => _error;

  final List<UploadFileItem> _selectedFiles = [];
  List<UploadFileItem> get selectedFiles => List.unmodifiable(_selectedFiles);

  CancelToken? _cancelToken;
  bool _disposed = false;

  // Guards against a stale request's callback/timeout/catch block mutating
  // state after the user has already cancelled or started a new operation.
  int _requestId = 0;

  double get totalProgress {
    if (_selectedFiles.isEmpty) return 0.0;
    final sum = _selectedFiles.fold<double>(
        0.0, (previous, element) => previous + element.progress);
    return sum / _selectedFiles.length;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _setStatus(UploadStatus status) {
    if (_disposed) return;
    _status = status;
    _safeNotify();
  }

  /// STEP 1: Safe File Picker Execution (Guarantees State Reset on Cancel)
  Future<void> pickFiles() async {
    if (_status == UploadStatus.picking || _status == UploadStatus.uploading) {
      return;
    }

    _setStatus(UploadStatus.picking);
    _error = null;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        _setStatus(_selectedFiles.isNotEmpty
            ? UploadStatus.readyToUpload
            : UploadStatus.idle);
        return;
      }

      _selectedFiles.clear();

      for (var f in result.files) {
        if (f.path == null) continue;
        final fileObject = File(f.path!);
        if (await fileObject.exists()) {
          _selectedFiles.add(
            UploadFileItem(
              id: '${f.path}_${DateTime.now().microsecondsSinceEpoch}',
              file: fileObject,
              fileName: f.name,
              fileSize: f.size,
            ),
          );
        }
      }

      if (_selectedFiles.isEmpty) {
        _error = 'Selected files are inaccessible or empty.';
        _setStatus(UploadStatus.error);
      } else {
        _setStatus(UploadStatus.readyToUpload);
      }
    } catch (e) {
      _error = 'Exception while picking files: ${e.toString()}';
      _setStatus(UploadStatus.error);
    }
  }

  /// STEP 2: Cancellable, timeout-protected upload.
  Future<List<CaseFileModel>> uploadFiles(String caseId) async {
    if (_selectedFiles.isEmpty || _status == UploadStatus.uploading) {
      return [];
    }

    final int requestId = ++_requestId;
    _cancelToken = CancelToken();
    _error = null;
    _setStatus(UploadStatus.uploading);

    try {
      final uploadedFiles = await _repo
          .addFilesToCase(
            caseId: caseId,
            files: _selectedFiles.map((e) => e.file).toList(),
            cancelToken: _cancelToken,
            onProgress: (sent, total) {
              // Ignore progress from a request that's been superseded
              // (cancelled / reset / a new upload started).
              if (requestId != _requestId || total <= 0) return;
              final globalProgress = (sent / total).clamp(0.0, 1.0);
              for (var item in _selectedFiles) {
                item.progress = globalProgress;
              }
              _safeNotify();
            },
          )
          .timeout(_kUploadTimeout);

      if (requestId != _requestId) return []; // superseded, ignore result
      _setStatus(UploadStatus.success);
      return uploadedFiles;
    } on TimeoutException {
      if (requestId != _requestId) return [];
      _cancelToken?.cancel('Upload timed out');
      _error = 'Upload timed out. Please check your connection and try again.';
      _setStatus(UploadStatus.error);
      return [];
    } on DioException catch (e) {
      if (requestId != _requestId) return [];
      if (e.type == DioExceptionType.cancel) {
        _setStatus(UploadStatus.cancelled);
        return [];
      }
      _error = 'Upload failed: ${e.message ?? "connection error"}';
      _setStatus(UploadStatus.error);
      return [];
    } catch (e) {
      if (requestId != _requestId) return [];
      _error = 'Upload pipeline failure. Connection dropped or aborted.';
      _setStatus(UploadStatus.error);
      return [];
    } finally {
      if (requestId == _requestId) {
        _cancelToken = null;
      }
    }
  }

  /// Cancels any in-flight request and clears all local state. Safe to call
  /// at any time — including mid-upload, which is the whole point.
  void cancelUploadWorkflow() {
    _requestId++; // invalidate any in-flight callbacks/timeouts immediately
    _cancelToken?.cancel('Cancelled by user');
    _cancelToken = null;
    _selectedFiles.clear();
    _error = null;
    _status = UploadStatus.idle;
    _safeNotify();
  }

  /// Kept as an alias for readability at call sites; identical to
  /// cancelUploadWorkflow now that both always fully tear down state + network.
  void resetState() => cancelUploadWorkflow();

  @override
  void dispose() {
    _cancelToken?.cancel('ViewModel disposed');
    _disposed = true;
    super.dispose();
  }
}
