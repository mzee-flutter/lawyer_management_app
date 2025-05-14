import 'package:flutter/material.dart';
import '../../models/case_model.dart';
import 'package:uuid/uuid.dart';

class CaseViewModel extends ChangeNotifier {
  final List<CaseModel> _cases = [];
  List<CaseModel> get cases => _cases;

  void addCase(
      String title, String description, String clientId, String status) {
    _cases.add(CaseModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      clientId: clientId,
      status: status,
    ));
    notifyListeners();
  }
}
