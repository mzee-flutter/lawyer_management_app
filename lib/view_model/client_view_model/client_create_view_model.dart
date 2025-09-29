import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:right_case/models/client_models/client_create_model.dart';
import 'package:right_case/repository/client_repository/client_create_repo.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientCreateViewModel extends ChangeNotifier {
  final ClientCreateRepo _clientCreateRepo = ClientCreateRepo();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> submitClient(context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final cnic = cnicController.text.trim();
    final address = addressController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Name is required'))),
      );
      return;
    }

    final newClient = ClientCreateModel(
        name: name,
        email: email,
        phone: mobile,
        cnic: cnic,
        address: address,
        notes: notes);

    try {
      final dbClient = await _clientCreateRepo.createClient(newClient);
      Provider.of<ClientListViewModel>(context, listen: false)
          .addClient(dbClient);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error in ClientCreateViewModel: $e");
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    cnicController.clear();
    addressController.clear();
    notesController.clear();
    notifyListeners();
  }

  void disposeController() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    cnicController.clear();

    addressController.dispose();
    notesController.clear();
    super.dispose();
  }
}
