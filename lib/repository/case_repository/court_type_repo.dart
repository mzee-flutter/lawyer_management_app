import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class CourtTypeRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<List<CourtCategoryModel>> fetchCourtTypes() async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getAllCategories,
        CaseUrls.headers,
      );
      final data = response as List<dynamic>;
      final courtTypeList =
          data.map((type) => CourtCategoryModel.fromJson(type)).toList();
      return courtTypeList;
    } catch (e) {
      debugPrint("Error in courtTypeRepo:${e.toString()}");
      rethrow;
    }
  }
}
