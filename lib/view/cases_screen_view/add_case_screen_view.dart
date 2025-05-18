import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/add_case_view_model.dart';

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
            padding: EdgeInsets.all(16.0.r),
            child: ListView(
              children: [
                CustomTextField.fieldLabel('Enter Case Title'),
                CustomTextField(controller: addCaseVM.titleController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Enter Case Description'),
                CustomTextField(controller: addCaseVM.descController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Enter Client ID'),
                CustomTextField(controller: addCaseVM.clientIdController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Select Case Status'),
                DropdownButtonFormField<String>(
                  focusColor: Colors.grey.shade300,
                  dropdownColor: Colors.grey.shade300,
                  value: addCaseVM.statusController.text.isNotEmpty
                      ? addCaseVM.statusController.text
                      : null,
                  items: [
                    'None',
                    'Running',
                    'Decided',
                    'Date Awaited',
                    'Abandoned'
                  ]
                      .map((status) => DropdownMenuItem(
                            value: status == 'None' ? '' : status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      addCaseVM.statusController.text = value;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  ),
                ),
                SizedBox(height: 20.h),
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
}
