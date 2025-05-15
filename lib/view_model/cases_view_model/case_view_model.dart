import 'package:flutter/material.dart';
import '../../models/case_model.dart';

class CaseViewModel extends ChangeNotifier {
  final List<CaseModel> _cases = [];
  List<CaseModel> get cases => _cases;

  void addCase(CaseModel clientCase) {
    _cases.add(clientCase);
    notifyListeners();
  }

  void removeCase(CaseModel clientCase) {
    _cases.remove(clientCase);
    notifyListeners();
  }
}
