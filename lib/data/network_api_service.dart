import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/repository/auth_repository/refresh_access_token_repo.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

// --- CUSTOM EXCEPTION LAYER EXTENSIONS ---
// Make sure to add these to your right_case/data/api_exception.dart file

class NetworkApiServices extends BaseApiServices {
  final TokenStorageService _tokenStorage = TokenStorageService();
  late final RefreshAccessTokenRepo _refreshRepo;

  NetworkApiServices() {
    _refreshRepo = RefreshAccessTokenRepo(this);
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function(Map<String, String>) requestFunction, {
    Map<String, String>?
        customHeaders, // Fix 1: Accept optional target header overrides
  }) async {
    final token = await _tokenStorage.getAccessToken();

    // Establish fundamental basic structural components
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
      ...?customHeaders, // Safely combine unique extra headers if passed
    };

    http.Response response;

    try {
      response = await requestFunction(headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FetchDataException("Request timed out"),
      );

      // --- ADVANCED 401 INTERCEPTOR LOGIC HANDLING ---
      if (response.statusCode == 401) {
        debugPrint(
            "401 Unauthorized detected. Attempting atomic token token replacement pipeline...");
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (refreshToken == null) {
          throw UnauthorizedRequestException(
              "Session expired. No Refresh Token Found.");
        }

        try {
          // Attempt token exchange
          await _refreshRepo.getFreshAccessToken(refreshToken);
          final newAccessToken = await _tokenStorage.getAccessToken();

          // Apply fresh token to headers and retry the exact same request closure safely
          headers["Authorization"] = "Bearer $newAccessToken";
          response = await requestFunction(headers);
        } catch (refreshError) {
          debugPrint(
              "Critical Token Refresh Failed. Purging credential store parameters: $refreshError");
          // Clear active keys immediately to force the user back to Login safely
          await _tokenStorage.clearTokens();
          throw UnauthorizedRequestException(
              "Session completely expired. Please log in again.");
        }
      }

      return _checkAndReturnApiResponse(response);
    } on ApiException {
      rethrow; // Pass up custom infrastructure exceptions without mutations
    } on SocketException catch (e) {
      debugPrint("SocketException: $e");
      throw FetchDataException("No Internet Connection: ${e.message}");
    } on http.ClientException catch (e) {
      debugPrint("ClientException: $e");
      throw FetchDataException("HTTP client connection dropped: ${e.message}");
    } catch (e, stack) {
      debugPrint("Unhandled System Exception Core: $e");
      debugPrint(stack.toString());
      throw FetchDataException("An unexpected error occurred.");
    }
  }

  @override
  Future getGetApiRequest(
    String url,
    Map<String, dynamic>? header, {
    Map<String, dynamic>? query, // Existing optional named parameter
  }) async {
    final Map<String, String>? stringHeaders =
        header?.map((k, v) => MapEntry(k, v.toString()));

    return _sendRequest(
      (headers) {
        var uri = Uri.parse(url);
        if (query != null && query.isNotEmpty) {
          final Map<String, dynamic> stringQuery =
              query.map((k, v) => MapEntry(k, v.toString()));

          uri = uri.replace(queryParameters: stringQuery);
        }
        return http.get(uri, headers: headers);
      },
      customHeaders: stringHeaders,
    );
  }

  @override
  Future getPostApiRequest(
    String url,
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) async {
    final Map<String, String> stringHeaders =
        header.map((k, v) => MapEntry(k, v.toString()));
    return _sendRequest(
      (headers) =>
          http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      customHeaders: stringHeaders,
    );
  }

  @override
  Future getPutApiRequest(
    String url,
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) async {
    final Map<String, String> stringHeaders =
        header.map((k, v) => MapEntry(k, v.toString()));
    return _sendRequest(
      (headers) =>
          http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      customHeaders: stringHeaders,
    );
  }

  @override
  Future getDeleteApiRequest(String url, Map<String, dynamic> body) async {
    return _sendRequest(
      (headers) =>
          http.delete(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
  }

  @override
  Future getPatchApiRequest(
    String url,
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) async {
    final Map<String, String> stringHeaders =
        header.map((k, v) => MapEntry(k, v.toString()));
    return _sendRequest(
      (headers) =>
          http.patch(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      customHeaders: stringHeaders,
    );
  }

  dynamic _checkAndReturnApiResponse(http.Response response) {
    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      responseData = null;
    }

    final String serverErrorMessage = extractErrorMessage(responseData);

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseData;

      case 400:
        throw BadRequestException(serverErrorMessage);

      case 401:
      case 403:
        throw UnauthorizedRequestException(serverErrorMessage);

      // FIX 2: Explicit structural catching of HTTP 404 codes to support your dynamic repository checks
      case 404:
        throw NotFoundException(serverErrorMessage.isNotEmpty
            ? serverErrorMessage
            : "Requested resource not found.");

      case 409:
        throw DuplicateAutoTaskException(serverErrorMessage);

      case 500:
      default:
        throw FetchDataException(
          serverErrorMessage.isNotEmpty
              ? serverErrorMessage
              : "Error occurred status code: ${response.statusCode}",
        );
    }
  }

  String extractErrorMessage(dynamic responseBody) {
    if (responseBody is Map && responseBody['detail'] != null) {
      final detail = responseBody['detail'];

      if (detail is String) {
        return detail;
      }

      if (detail is List) {
        return detail.map((e) => e['msg'] ?? 'Invalid input format').join(', ');
      }
    }
    return '';
  }
}
