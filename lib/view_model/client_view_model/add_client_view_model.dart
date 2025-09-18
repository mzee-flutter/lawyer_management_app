import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_model.dart';
import 'package:right_case/view_model/client_view_model.dart';
import 'package:uuid/uuid.dart';

class AddClientViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void submitClient(context) {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Name is required'))),
      );
      return;
    }

    final newClient = ClientModel(
      id: const Uuid().v4(),
      name: name,
      mobileNumber: mobile,
      emailAddress: email,
      address: address,
      createdAt: DateTime.now(),
    );

    Provider.of<ClientViewModel>(context, listen: false).addClient(newClient);
    Navigator.pop(context);
  }

  void clearFields() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    addressController.clear();
    notifyListeners();
  }

  void disposeController() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
