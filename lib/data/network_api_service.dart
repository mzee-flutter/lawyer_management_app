import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/repository/auth_repository/refresh_access_token_repo.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class NetworkApiServices extends BaseApiServices {
  final TokenStorageService _tokenStorage = TokenStorageService();
  late final RefreshAccessTokenRepo _refreshRepo;

  NetworkApiServices() {
    _refreshRepo = RefreshAccessTokenRepo(this);
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function(Map<String, String>) requestFunction, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    http.Response response;

    try {
      response = await requestFunction(headers).timeout(Duration(seconds: 13),
          onTimeout: () => throw FetchDataException("Request time out"));

      if (response.statusCode == 401) {
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (refreshToken == null) {
          throw UnauthorizedRequestException("No Refresh Token Found");
        }
        await _refreshRepo.getFreshAccessToken(refreshToken);
        final newAccessToken = await _tokenStorage.getAccessToken();

        headers["Authorization"] = "Bearer $newAccessToken";
        response = await requestFunction(headers);
      }
      return _checkAndReturnApiResponse(response);
    } on SocketException catch (e) {
      debugPrint("SocketException: $e");
      throw FetchDataException("Network error: ${e.message}");
    } on http.ClientException catch (e) {
      debugPrint("ClientException: $e");
      throw FetchDataException("HTTP client error: ${e.message}");
    } catch (e, stack) {
      debugPrint("Unknown error: $e");
      debugPrint(stack.toString());
      throw FetchDataException("Unexpected error: $e");
    }
  }

  @override
  Future getGetApiRequest(String url, Map<String, dynamic>? header) async {
    return _sendRequest(
      (headers) => http.get(Uri.parse(url), headers: headers),
    );
  }

  @override
  Future getPostApiRequest(
    String url,
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) async {
    return _sendRequest(
      (headers) =>
          http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
  }

  @override
  Future getPutApiRequest(
    String url,
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) async {
    return _sendRequest(
      (headers) =>
          http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)),
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
    return _sendRequest(
      (headers) =>
          http.patch(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
  }

  dynamic _checkAndReturnApiResponse(http.Response response) {
    switch (response.statusCode) {
      case 200 || 201:
        return jsonDecode(response.body);

      case 400:
        throw BadRequestException("Bad request");

      case 401:
      case 403:
        throw UnauthorizedRequestException("Unauthorized");

      case 500:
      default:
        throw FetchDataException("Error occurred: ${response.statusCode}");
    }
  }
}
