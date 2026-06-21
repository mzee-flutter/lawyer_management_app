import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class AddCaseFileRepo {
  final Dio _dio = Dio();
  Future<List<CaseFileModel>> addFilesToCase({
    required String caseId,
    required List<File> files,
    Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData();
    try {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path),
          ),
        );
      }

      final response = await _dio.post(
        CaseUrls.uploadCaseFile(caseId),
        data: formData,
        onSendProgress: onProgress,
      );

      return (response.data as List)
          .map((e) => CaseFileModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint("Error in AddCaseFileRepo: $e");
      rethrow;
    }
  }
}
