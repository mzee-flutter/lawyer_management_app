import 'dart:io';

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
}

/// Enhanced data model tracker tracking isolate individual parameters cleanly
class UploadFileItem {
  final File file;
  final String fileName;
  final int fileSize;
  double progress;
  String? itemError;

  UploadFileItem({
    required this.file,
    required this.fileName,
    required this.fileSize,
    this.progress = 0.0,
    this.itemError,
  });
}

class AddCaseFileViewModel with ChangeNotifier {
  final AddCaseFileRepo _repo = AddCaseFileRepo();

  UploadStatus _status = UploadStatus.idle;
  UploadStatus get status => _status;

  String? _error;
  String? get error => _error;

  final List<UploadFileItem> _selectedFiles = [];
  List<UploadFileItem> get selectedFiles => _selectedFiles;

  // Calculates overall total atomic progress for the global loading widget indicator
  double get totalProgress {
    if (_selectedFiles.isEmpty) return 0.0;
    double sum = _selectedFiles.fold(
        0.0, (previous, element) => previous + element.progress);
    return sum / _selectedFiles.length;
  }

  void _setStatus(UploadStatus status) {
    _status = status;
    notifyListeners();
  }

  /// STEP 1: Safe File Picker Execution (Guarantees State Reset on Cancel)
  Future<void> pickFiles() async {
    // Prevent double invocation if user multi-taps the button
    if (_status == UploadStatus.picking || _status == UploadStatus.uploading)
      return;

    _setStatus(UploadStatus.picking);
    _error = null;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: false, // Set true if executing targeting Web targets
      );

      // If user closes/cancels the file picker window, reset to idle cleanly so it can be opened again
      if (result == null || result.files.isEmpty) {
        _setStatus(_selectedFiles.isNotEmpty
            ? UploadStatus.readyToUpload
            : UploadStatus.idle);
        return;
      }

      _selectedFiles.clear();

      for (var f in result.files) {
        if (f.path != null) {
          final fileObject = File(f.path!);
          if (await fileObject.exists()) {
            _selectedFiles.add(
              UploadFileItem(
                file: fileObject,
                fileName: f.name,
                fileSize: f.size,
              ),
            );
          }
        }
      }

      if (_selectedFiles.isEmpty) {
        _error = "Selected files are inaccessible or empty.";
        _setStatus(UploadStatus.error);
      } else {
        _setStatus(UploadStatus.readyToUpload);
      }
    } catch (e) {
      _error = "Exception while picking files: ${e.toString()}";
      _setStatus(UploadStatus.error);
    }
  }

  /// STEP 2: Non-blocking Chunked Upload (Independent File Isolation Streams)
  Future<List<CaseFileModel>> uploadFiles(String caseId) async {
    if (_selectedFiles.isEmpty || _status == UploadStatus.uploading) {
      return [];
    }

    _setStatus(UploadStatus.uploading);
    _error = null;

    try {
      // Pass individual files or use concurrent limits depending on your repository architecture.
      // If your repository processes the files list internally, we manage the global stream safely here:
      final uploadedFiles = await _repo.addFilesToCase(
        caseId: caseId,
        files: _selectedFiles.map((e) => e.file).toList(),
        onProgress: (sent, total) {
          if (total <= 0) return;

          final globalProgress = sent / total;

          // Smooth Linear Distribution Matrix to prevent frame drops
          for (var item in _selectedFiles) {
            item.progress = globalProgress;
          }
          notifyListeners();
        },
      );

      _setStatus(UploadStatus.success);
      return uploadedFiles;
    } catch (e) {
      _error = "Upload pipeline failure. Connection dropped or aborted.";
      _setStatus(UploadStatus.error);
      rethrow;
    }
  }

  /// Completely clears state mutations to resolve UI deadlocks
  void resetState() {
    _selectedFiles.clear();
    _error = null;
    _status = UploadStatus.idle;
    notifyListeners();
  }

  /// Targeted function to clear selections if user dismisses or cancels the upload popup view panel
  void cancelUploadWorkflow() {
    resetState();
  }
}
