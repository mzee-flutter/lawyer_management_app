import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_create_model.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/repository/case_repository/case_create_repo.dart';

class CaseCreateViewModel with ChangeNotifier {
  final CaseCreateRepo _caseCreateRepo = CaseCreateRepo();
  final TextEditingController caseNumberController = TextEditingController();
  final TextEditingController courtNameController = TextEditingController();
  final TextEditingController judgeNameController = TextEditingController();
  final TextEditingController firstPartyNameController =
      TextEditingController();
  final TextEditingController oppositePartyNameController =
      TextEditingController();
  final TextEditingController caseNotesController = TextEditingController();
  final TextEditingController legalFeesController = TextEditingController();

  // Registration Date
  DateTime? _registrationDate;
  DateTime? get registrationDate => _registrationDate;

  void setRegistrationDate(DateTime? date) {
    if (date != null) {
      _registrationDate = date;
    }
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<CaseModel> createCase({
    required String courtCategoryId,
    required String caseTypeId,
    required String caseStageId,
    required String caseStatusId,
    required context, // only for snackbar/navigation
  }) async {
    final createCase = CaseCreateModel(
      caseNumber: caseNumberController.text.trim(),
      registrationDate: registrationDate ?? DateTime.now(),
      courtName: courtNameController.text.trim(),
      judgeName: judgeNameController.text.trim(),
      firstPartyName: firstPartyNameController.text.trim(),
      oppositePartyName: oppositePartyNameController.text.trim(),
      courtCategoryId: courtCategoryId,
      caseTypeId: caseTypeId,
      caseStageId: caseStageId,
      caseStatusId: caseStatusId,
      caseNotes: caseNotesController.text.trim(),
      legalFees: double.tryParse(legalFeesController.text.trim()),
      relatedFiles: [],
      status: "active",
    );

    try {
      setLoading(true);
      final dbCase = await _caseCreateRepo.createCase(createCase);

      return dbCase;
    } catch (e) {
      debugPrint("Error in CaseCreateViewModel: ${e.toString()}");
      rethrow;
    } finally {
      setLoading(false);
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

  @override
  void dispose() {
    caseNumberController.dispose();
    courtNameController.dispose();
    judgeNameController.dispose();
    firstPartyNameController.dispose();
    oppositePartyNameController.dispose();
    caseNotesController.dispose();
    legalFeesController.dispose();
    super.dispose();
  }
}
