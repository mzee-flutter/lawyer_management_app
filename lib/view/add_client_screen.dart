import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/add_client_view_model.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  late AddClientViewModel addClientViewModel;

  @override
  void initState() {
    super.initState();
    addClientViewModel =
        Provider.of<AddClientViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Consumer<AddClientViewModel>(
            builder: (context, addClientViewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabels('Enter Client Name*'),
                  _buildTextField(addClientViewModel.nameController),
                  const SizedBox(height: 12),
                  _buildLabels('Enter Client Mobile Number (Optional)'),
                  _buildTextField(
                    addClientViewModel.mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 12,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      SpaceAfterFourDigitsFormatter(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLabels('Enter Client EmailID (Optional)'),
                  _buildTextField(addClientViewModel.emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildLabels('Enter Client Address (Optional)'),
                  _buildTextField(addClientViewModel.addressController,
                      maxLines: 2),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      addClientViewModel.submitClient(context);
                      addClientViewModel.clearFields();
                    },
                    icon: const Icon(Icons.person_add_alt, color: Colors.white),
                    label: const Text(
                      'Add Client',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
      cursorColor: Colors.grey.shade800,
      maxLength: maxLength,
      inputFormatters: inputFormatter,
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
