import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';

class EditCaseViewModel with ChangeNotifier {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController clientIdController;
  late TextEditingController statusController;

  late CaseModel _originalCase;

  void initializeFields(CaseModel clientCase) {
    _originalCase = clientCase;
    titleController = TextEditingController(text: clientCase.title);
    descController = TextEditingController(text: clientCase.description);
    clientIdController = TextEditingController(text: clientCase.clientId);
    statusController = TextEditingController(text: clientCase.status);
  }

  void saveChanges(context) {
    final updateCase = CaseModel(
      id: _originalCase.id,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      clientId: clientIdController.text.trim(),
      status: statusController.text.trim(),
      createdAt: _originalCase.createdAt,
    );

    Provider.of<CaseViewModel>(context, listen: false).updateCase(updateCase);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    clientIdController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
