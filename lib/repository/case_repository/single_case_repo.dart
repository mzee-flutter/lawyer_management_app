import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

class SingleCaseRepo {
  final BaseApiServices _services = NetworkApiServices();

  Future<CaseModel> fetchSingleCase(String caseId) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getCase(caseId),
        CaseUrls.headers,
      );
      final caseData = CaseModel.fromJson(response);

      return caseData;
    } catch (e) {
      rethrow;
    }
  }
}
