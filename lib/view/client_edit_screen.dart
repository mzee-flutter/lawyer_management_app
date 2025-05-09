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
                _buildLabels('Enter Client Name*'),
                _buildTextField(editViewModel.nameController),
                SizedBox(
                  height: 12.h,
                ),
                _buildLabels('Enter Client Mobile Number(Optional)'),
                _buildTextField(editViewModel.phoneController,
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
                _buildLabels('Enter Client EmailID (Optional)'),
                _buildTextField(
                  editViewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 12.h,
                ),
                _buildLabels('Enter Client Address (Optional)'),
                _buildTextField(editViewModel.addressController, maxLines: 2),
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

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatter,
      cursorColor: Colors.grey.shade800,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLabels(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
    );
  }
}
