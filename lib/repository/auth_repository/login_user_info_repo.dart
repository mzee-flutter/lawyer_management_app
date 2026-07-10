import 'package:flutter/foundation.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

import '../../data/api_exception.dart';

class LoginUserInfoRepository {
  final BaseApiServices _services = NetworkApiServices();

  Future<User> fetchLoginUserInfo(String? token) async {
    if (token == null || token.isEmpty) {
      // Same exception type NetworkApiServices already throws for a
      // rejected token, instead of a second, unrelated "Unauthorized"
      // class that callers' catch clauses would never actually match.
      throw UnauthorizedRequestException('No access token available');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _services.getGetApiRequest(
        '${AuthURL.baseURl}/me',
        headers,
      );
      return User.fromJson(response);
    } catch (e) {
      debugPrint('LoginUserInfoRepository error: $e');
      rethrow;
    }
  }
}
