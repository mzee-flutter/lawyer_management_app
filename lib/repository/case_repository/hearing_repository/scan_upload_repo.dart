import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:right_case/resources/URLs/case_urls.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

import '../../../models/case_models/scan_model.dart';

class ScanUploadRepo {
  final TokenStorageService tokenService = TokenStorageService();
  final Dio _dio = Dio(
    BaseOptions(
      // Time allowed just to establish the connection to the server.
      connectTimeout: const Duration(seconds: 15),
    ),
  );

  Future<ScanExtractionModel> extractFromImage({
    required File image,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData();
    final token = await tokenService.getAccessToken();
    try {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(image.path)),
      );

      final response = await _dio.post(
        CaseUrls.scanExtract,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          // Longer than a plain file upload — the server does the image
          // save AND waits on the vision API call before responding.
          receiveTimeout: const Duration(seconds: 45),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ScanExtractionModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint("Error in ScanUploadRepo: ${e.type} — ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error in ScanUploadRepo: $e");
      rethrow;
    }
  }
}
