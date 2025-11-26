import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/case_create_model.dart';
import 'package:right_case/repository/case_repository/case_create_repo.dart';

class CaseCreateViewModel with ChangeNotifier {
  final CaseCreateRepo _caseCreateRepo = CaseCreateRepo();
  final TextEditingController caseNumberController = TextEditingController();
  final TextEditingController courtNameController = TextEditingController();
  final TextEditingController judgeNameController = TextEditingController();
  final TextEditingController oppositePartyNameController =
      TextEditingController();
  final TextEditingController caseNotesController = TextEditingController();
  final TextEditingController legalFeesController = TextEditingController();

  // UUID fields selected from dropdowns
  String? firstPartyId;
  String? secondPartyId;
  String? courtCategoryId;
  String? caseTypeId;
  String? caseStageId;
  String? caseStatusId;

  // Registration Date
  DateTime? registrationDate;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> createCase(BuildContext context) async {
    if (firstPartyId == null || secondPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both parties")),
      );
      return;
    }

    final model = CaseCreateModel(
      caseNumber: caseNumberController.text.trim(),
      registrationDate: registrationDate ?? DateTime.now(),
      courtName: courtNameController.text.trim(),
      judgeName: judgeNameController.text.trim(),
      firstPartyId: firstPartyId,
      secondPartyId: secondPartyId,
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
      await _caseCreateRepo.createCase(model);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Case created successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setLoading(false);
    }
  }
}
