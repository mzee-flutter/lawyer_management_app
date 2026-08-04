import 'package:all/all.dart';
import 'package:right_case/repository/case_repository/single_case_repo.dart';

import '../../models/case_models/case_model.dart';

class SingleCaseViewModel with ChangeNotifier {
  final SingleCaseRepo _singleCaseRepo = SingleCaseRepo();

  CaseModel? _singleCaseData;
  CaseModel? get singleCaseData => _singleCaseData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoader(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> fetchSingleCase(String caseId) async {
    toggleLoader(true);
    try {
      final fetchedCaseData = await _singleCaseRepo.fetchSingleCase(caseId);
      _singleCaseData = fetchedCaseData;
    } catch (e) {
      throw Exception("Error In SingleCaseViewModel:$e");
    } finally {
      toggleLoader(false);
    }
  }
}
