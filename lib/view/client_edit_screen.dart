import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_model.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/client_edit_view_model.dart';

class ClientEditScreen extends StatefulWidget {
  final ClientModel client;

  const ClientEditScreen({super.key, required this.client});

  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  late ClientEditViewModel editViewModel;
  @override
  void initState() {
    super.initState();
    editViewModel = Provider.of<ClientEditViewModel>(context, listen: false);
    editViewModel.initializeFields(widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Client"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Consumer<ClientEditViewModel>(
        builder: (context, editViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                CustomTextField.fieldLabel('Enter Client Name*'),
                CustomTextField(controller: editViewModel.nameController),
                SizedBox(
                  height: 12.h,
                ),
                CustomTextField.fieldLabel(
                    'Enter Client Mobile Number(Optional)'),
                CustomTextField(
                    controller: editViewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 12,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      SpaceAfterFourDigitsFormatter(),
                    ]),
                SizedBox(
                  height: 12.h,
                ),
                CustomTextField.fieldLabel('Enter Client EmailID (Optional)'),
                CustomTextField(
                  controller: editViewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Enter Client Address (Optional)'),
                CustomTextField(
                  controller: editViewModel.addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800),
                  onPressed: () {
                    editViewModel.saveChanges(context);
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
