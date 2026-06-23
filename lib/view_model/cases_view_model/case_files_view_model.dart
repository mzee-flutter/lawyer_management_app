import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

class CaseFilesViewModel with ChangeNotifier {
  final String caseId;
  CaseFilesViewModel({required this.caseId});

  List<CaseFileModel> _files = [];
  List<CaseFileModel> get files => List.unmodifiable(_files);

  final bool _loading = false;
  bool get loading => _loading;

  void loadFilesFromCase(BuildContext context) {
    final caseData = context.read<CaseListViewModel>().getCaseById(caseId);

    _files = List.from(caseData?.files ?? []);
    notifyListeners();
  }

  /// we have to check that is it work to add the files locally after the last file
  /// (just to check the index works or not otherwise we will again make it 0)
  void addFile(BuildContext context, List<CaseFileModel> files) {
    _files.insertAll(0, files);
    notifyListeners();
    _syncToCase(context);
  }

  void removeFile(BuildContext context, String fileId) {
    _files.removeWhere((f) => f.id == fileId);
    notifyListeners();
    _syncToCase(context);
  }

  void _syncToCase(BuildContext context) {
    context.read<CaseListViewModel>().updateCaseFiles(
          caseId: caseId,
          files: List.unmodifiable(_files),
        );
  }

  void clear() {
    _files.clear();
    notifyListeners();
  }
}
