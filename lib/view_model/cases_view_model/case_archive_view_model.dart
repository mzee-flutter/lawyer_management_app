import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/case_repository/case_archive_repo.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

class CaseArchiveViewModel with ChangeNotifier {
  final CaseArchiveRepo _caseArchiveRepo = CaseArchiveRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> archiveCase(context, String id) async {
    toggleLoading(true);
    try {
      final dbCase = await _caseArchiveRepo.archiveCase(id);
      toggleLoading(false);
      Provider.of<CaseListViewModel>(context, listen: false).removeCase(dbCase);
    } catch (e) {
      debugPrint("Error in CaseArchiveViewModel: $e");
    } finally {
      toggleLoading(false);
    }
  }
}
