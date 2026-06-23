import 'package:flutter/cupertino.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/remove_case_file_repo.dart';

class RemoveCaseFileViewModel with ChangeNotifier {
  final RemoveCaseFileRepo _removeCaseFileRepo = RemoveCaseFileRepo();

  Future<CaseFileModel> removeFileFromCase(String fileId) async {
    try {
      final caseFile = await _removeCaseFileRepo.removeFileFromCase(fileId);

      notifyListeners();

      return caseFile;
    } catch (e) {
      debugPrint("Error in RemoveCaseFileViewModel: $e");
      rethrow;
    } finally {}
  }
}
