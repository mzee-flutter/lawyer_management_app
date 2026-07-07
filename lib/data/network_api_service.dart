import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/repository/auth_repository/refresh_access_token_repo.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

import '../view_model/services/auth_event_bus.dart';

class NetworkApiServices extends BaseApiServices {
  final TokenStorageService _tokenStorage = TokenStorageService();
  late final RefreshAccessTokenRepo _refreshRepo;

  NetworkApiServices() {
    _refreshRepo = RefreshAccessTokenRepo(this);
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function(Map<String, String>) requestFunction, {
    Map<String, String>? customHeaders,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
      ...?customHeaders,
    };

    http.Response response;

    try {
      response = await requestFunction(headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FetchDataException("Request timed out"),
      );

      if (response.statusCode == 401) {
        debugPrint("401 received — attempting token refresh.");
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (refreshToken == null) {
          await _tokenStorage.clearTokens();
          AuthEventBus.instance.fireForceLogout();
          throw UnauthorizedRequestException(
              "Session expired. No refresh token found.");
        }

        try {
          await _refreshRepo.getFreshAccessToken(refreshToken);
          final newAccessToken = await _tokenStorage.getAccessToken();

          headers["Authorization"] = "Bearer $newAccessToken";
          response = await requestFunction(headers);
        } catch (refreshError) {
          debugPrint("Refresh token rejected: $refreshError");
          await _tokenStorage.clearTokens();
          // This is the piece that was missing before: clearing tokens
          // alone doesn't tell the rest of the app anything changed. Any
          // screen mid-navigation-stack would keep behaving as if it were
          // still logged in until its next API call also 401'd. Firing
          // this event lets CurrentUserViewModel react immediately,
          // regardless of which screen triggered the failing request.
          AuthEventBus.instance.fireForceLogout();
          throw UnauthorizedRequestException(
              "Session completely expired. Please log in again.");
        }
      }

      return _checkAndReturnApiResponse(response);
    } on ApiException {
      rethrow;
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
    Map<String, dynamic>? query,
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
