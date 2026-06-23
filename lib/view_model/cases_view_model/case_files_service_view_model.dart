import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/case_resources/file_preview_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum FileLoadState { idle, loading, ready }

class CaseFilesServiceViewModel extends ChangeNotifier {
  final Map<String, FileLoadState> _fileStates = {};
  final Dio _dio = Dio();

  FileLoadState getFileState(String filename) {
    return _fileStates[filename] ?? FileLoadState.idle;
  }

  void _setState(String filename, FileLoadState state) {
    _fileStates[filename] = state;
    notifyListeners();
  }

  /// ---------- PUBLIC API ----------
  Future<void> openFile(
    BuildContext context,
    CaseFileModel file,
  ) async {
    _setState(file.filename, FileLoadState.loading);

    final lower = file.filename.toLowerCase();

    try {
      if (lower.endsWith(".pdf")) {
        final pdfFile = await _getCachedFile(
          file.fileUrl,
          file.filename,
        );

        _setState(file.filename, FileLoadState.ready);
        _openPdf(context, pdfFile, file.filename);
      } else if (lower.endsWith(".jpg") ||
          lower.endsWith(".jpeg") ||
          lower.endsWith(".png")) {
        _setState(file.filename, FileLoadState.ready);
        _openImage(context, file.fileUrl, file.filename);
      } else {
        await launchUrl(
          Uri.parse(file.fileUrl),
          mode: LaunchMode.externalApplication,
        );
        _setState(file.filename, FileLoadState.ready);
      }
    } catch (e) {
      _setState(file.filename, FileLoadState.idle);
    }
  }

  /// ---------- INTERNAL HELPERS ----------
  Future<File> _getCachedFile(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$filename';
    final file = File(path);

    if (await file.exists()) return file;

    await _dio.download(url, path);
    return file;
  }

  void _openPdf(BuildContext context, File file, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade300,
            title: Text(title),
          ),
          body: PDFView(filePath: file.path),
        ),
      ),
    );
  }

  void _openImage(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade300,
            title: Text(title),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (_, __) => const FilePreviewShimmer(),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
