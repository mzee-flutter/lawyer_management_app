import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';

class CaseCreateScreen extends StatefulWidget {
  const CaseCreateScreen({super.key});

  @override
  State<CaseCreateScreen> createState() => _CaseCreateScreenState();
}

class _CaseCreateScreenState extends State<CaseCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Case"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Consumer<CaseCreateViewModel>(
        builder: (context, caseCreateVM, child) {
          return Padding(
            padding: EdgeInsets.all(16.0.r),
            child: ListView(
              children: [
                CustomTextField.fieldLabel('Enter Case Title'),
                CustomTextField(controller: caseCreateVM.titleController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Enter Case Description'),
                CustomTextField(controller: caseCreateVM.descController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Enter Client ID'),
                CustomTextField(controller: caseCreateVM.clientIdController),
                SizedBox(height: 12.h),
                CustomTextField.fieldLabel('Select Case Status'),
                DropdownButtonFormField<String>(
                  focusColor: Colors.grey.shade300,
                  dropdownColor: Colors.grey.shade300,
                  value: caseCreateVM.statusController.text.isNotEmpty
                      ? caseCreateVM.statusController.text
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
                      caseCreateVM.statusController.text = value;
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
                    caseCreateVM.submitCase(context);
                    caseCreateVM.clearFields();
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
