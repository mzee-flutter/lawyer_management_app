import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_models/client_create_model.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_update_repo.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientUpdateViewModel with ChangeNotifier {
  final ClientUpdateRepo _clientUpdateRepo = ClientUpdateRepo();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cnicController;
  late TextEditingController addressController;
  late TextEditingController notesController;

  // late ClientModel _originalClient;

  void initializeFields(ClientModel client) {
    // _originalClient = client;
    nameController = TextEditingController(text: client.name);
    emailController = TextEditingController(text: client.email);
    phoneController = TextEditingController(text: client.phone);
    cnicController = TextEditingController(text: client.cnic);
    addressController = TextEditingController(text: client.address);
    notesController = TextEditingController(text: client.notes);
  }

  Future<void> saveChanges(context, String id) async {
    final updatedClient = ClientCreateModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      cnic: cnicController.text.trim(),
      address: addressController.text.trim(),
      notes: notesController.text.trim(),
    );

    try {
      final dbClient = await _clientUpdateRepo.clientUpdate(updatedClient, id);
      Provider.of<ClientListViewModel>(context, listen: false)
          .updateClient(dbClient);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error in ClientUpdateViewModel: $e");
    }
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
