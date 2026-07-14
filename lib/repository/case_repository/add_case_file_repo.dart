import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class AddCaseFileRepo {
  final Dio _dio = Dio(
    BaseOptions(
      // Time allowed just to establish the connection to the server.
      connectTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<CaseFileModel>> addFilesToCase({
    required String caseId,
    required List<File> files,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
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
        // This is the piece that lets Cancel / back-button actually abort
        // the socket instead of leaving the upload running in the
        // background after the UI has already moved on.
        cancelToken: cancelToken,
        options: Options(
          // Once the bytes are fully sent (the moment your progress bar
          // used to hit 100% and freeze), this is how long Dio itself will
          // wait for the server before giving up — independent of the
          // ViewModel's own 45s safety-net timer.
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;
      if (data is! List) {
        // Guards against a server error page / unexpected payload shape
        // crashing the cast below with an unhelpful stack trace.
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Unexpected response shape from server: ${data.runtimeType}',
          type: DioExceptionType.badResponse,
        );
      }

      return data.map((e) => CaseFileModel.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint("Error in AddCaseFileRepo: ${e.type} — ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error in AddCaseFileRepo: $e");
      rethrow;
    }
  }
}
