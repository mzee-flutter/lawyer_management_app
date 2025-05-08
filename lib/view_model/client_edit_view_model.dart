import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_model.dart';
import 'package:right_case/view_model/client_view_model.dart';

class ClientEditViewModel with ChangeNotifier {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  late ClientModel _originalClient;

  void initializeFields(ClientModel client) {
    _originalClient = client;
    nameController = TextEditingController(text: client.name);
    phoneController = TextEditingController(text: client.mobileNumber);
    emailController = TextEditingController(text: client.emailAddress ?? '');
    addressController = TextEditingController(text: client.address ?? '');
  }

  void saveChanges(context) {
    final updatedClient = ClientModel(
      id: _originalClient.id,
      name: nameController.text.trim(),
      mobileNumber: phoneController.text.trim(),
      emailAddress: emailController.text.trim(),
      address: addressController.text.trim(),
    );

    Provider.of<ClientViewModel>(context, listen: false)
        .updateClient(updatedClient);

    Navigator.pop(context);
  }

  void disposeControllersOnly() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void dispose() {
    disposeControllersOnly();
    super.dispose();
  }
}
