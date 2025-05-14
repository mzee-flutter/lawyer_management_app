import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view_model/cases_view_model/add_case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Case"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Consumer<AddCaseViewModel>(
        builder: (context, addCaseVM, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildLabels('Case Title'),
                _buildTextField(addCaseVM.titleController),
                const SizedBox(height: 16),
                _buildLabels('Enter Case Description'),
                _buildTextField(addCaseVM.descController),
                const SizedBox(height: 16),
                _buildLabels('Enter Client ID'),
                _buildTextField(addCaseVM.clientIdController),
                const SizedBox(height: 16),
                _buildLabels('Enter Case Status'),
                _buildTextField(addCaseVM.statusController),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    addCaseVM.submitCase(context);
                    addCaseVM.clearFields();
                  },
                  icon: const Icon(Icons.cases_rounded, color: Colors.white),
                  label: const Text(
                    'Add Case',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    minimumSize: const Size(double.infinity, 48),
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
