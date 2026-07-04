import 'package:flutter/cupertino.dart';
import 'package:right_case/models/case_models/case_create_model.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_update_repo.dart';

class CaseUpdateViewModel with ChangeNotifier {
  final CaseUpdateRepo _caseUpdateRepo = CaseUpdateRepo();
  final TextEditingController caseNumberController = TextEditingController();
  final TextEditingController courtNameController = TextEditingController();
  final TextEditingController judgeNameController = TextEditingController();
  final TextEditingController firstPartyNameController =
      TextEditingController();
  final TextEditingController oppositePartyNameController =
      TextEditingController();
  final TextEditingController caseNotesController = TextEditingController();
  final TextEditingController legalFeesController = TextEditingController();

  DateTime? registrationDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  void setRegistrationDate(DateTime? date) {
    registrationDate = date;
    notifyListeners();
  }

  void initializeCaseFields(CaseModel caseData) {
    registrationDate = caseData.registrationDate;
    caseNumberController.text = caseData.caseNumber;
    courtNameController.text = caseData.courtName ?? "";
    judgeNameController.text = caseData.judgeName ?? "";
    firstPartyNameController.text = caseData.firstPartyName;
    oppositePartyNameController.text = caseData.oppositePartyName ?? "";
    caseNotesController.text = caseData.caseNotes ?? "";
    legalFeesController.text = caseData.legalFees.toString();
    notifyListeners();
  }

  Future<CaseModel> saveCase({
    context,
    required String courtCategoryId,
    required String caseTypeId,
    required String caseStageId,
    required String caseStatusId,
    required String id,
  }) async {
    final updatedCase = CaseCreateModel(
      caseNumber: caseNumberController.text.trim(),
      registrationDate: registrationDate ?? DateTime.now(),
      firstPartyName: firstPartyNameController.text.trim(),
      oppositePartyName: oppositePartyNameController.text.trim(),
      courtCategoryId: courtCategoryId,
      caseTypeId: caseTypeId,
      courtName: courtNameController.text.trim(),
      judgeName: judgeNameController.text.trim(),
      caseStageId: caseStageId,
      caseStatusId: caseStatusId,
      caseNotes: caseNotesController.text.trim(),
      legalFees: double.tryParse(legalFeesController.text.trim()),
    );

    _toggleLoading(true);
    try {
      final dbCase = await _caseUpdateRepo.caseUpdate(updatedCase, id);
      return dbCase;
    } catch (e) {
      debugPrint("Error in CaseUpdateViewModel: $e");
      rethrow;
    } finally {
      _toggleLoading(false);
    }
  }

  void resetForm() {
    caseNumberController.clear();
    courtNameController.clear();
    judgeNameController.clear();
    firstPartyNameController.clear();
    oppositePartyNameController.clear();
    caseNotesController.clear();
    legalFeesController.clear();
  }

  void disposeControllersOnly() {
    caseNumberController.dispose();
    courtNameController.dispose();
    judgeNameController.dispose();
    firstPartyNameController.dispose();
    oppositePartyNameController.dispose();
    caseNotesController.dispose();
    legalFeesController.dispose();
    super.dispose();
  }

  @override
  void dispose() {
    disposeControllersOnly();
    super.dispose();
  }
}
