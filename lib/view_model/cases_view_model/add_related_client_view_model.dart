import 'package:flutter/cupertino.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/add_related_client_repo.dart';

class AddRelatedClientViewModel with ChangeNotifier {
  final AddRelatedClientRepo _repo = AddRelatedClientRepo();

  bool _loading = false;
  bool get loading => _loading;

  Future<List<RelatedClientModel>> addRelatedClients({
    required String caseId,
    required List<RelatedClientRequestModel> relatedClients,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      return await _repo.addRelatedClients(
        caseId,
        relatedClients,
      );
    } catch (e) {
      debugPrint("AddRelatedClientViewModel error: $e");
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
