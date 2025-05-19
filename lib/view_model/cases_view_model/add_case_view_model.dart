import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';
import 'package:uuid/uuid.dart';

class AddCaseViewModel with ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController clientIdController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  void submitCase(context) {
    final title = titleController.text.trim();
    final description = descController.text.trim();
    final clientID = clientIdController.text.trim();
    final status = statusController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Name is required'))),
      );
      return;
    }

    final newCase = CaseModel(
      id: Uuid().v4(),
      title: title,
      description: description,
      clientId: clientID,
      status: status,
      createdAt: DateTime.now(),
      nextHearingDate: DateTime.now(),
    );

    Provider.of<CaseViewModel>(context, listen: false).addCase(newCase);
    Navigator.pop(context);
  }

  void clearFields() {
    titleController.clear();
    descController.clear();
    clientIdController.clear();
    statusController.clear();
    notifyListeners();
  }

  void disposeController() {
    titleController.dispose();
    descController.dispose();
    clientIdController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
