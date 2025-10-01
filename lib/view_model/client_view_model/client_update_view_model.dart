import 'package:flutter/cupertino.dart';
import 'package:right_case/models/client_models/client_model.dart';

class ClientEditViewModel with ChangeNotifier {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  late ClientModel _originalClient;

  void initializeFields(ClientModel client) {
    _originalClient = client;
    nameController = TextEditingController(text: client.name);
    phoneController = TextEditingController(text: client.phone);
    emailController = TextEditingController(text: client.email ?? '');
    addressController = TextEditingController(text: client.address ?? '');
  }

  void saveChanges(context) {
    // final updatedClient = ClientModel(
    //   id: _originalClient.id,
    //   name: nameController.text.trim(),
    //   phone: phoneController.text.trim(),
    //   email: emailController.text.trim(),
    //   address: addressController.text.trim(),
    //   createdAt: _originalClient.createdAt,
    // );

    // Provider.of<ClientViewModel>(context, listen: false)
    //     .updateClient(updatedClient);

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
