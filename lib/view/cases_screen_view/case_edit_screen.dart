import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/edit_case_view_model.dart';

class EditCaseScreen extends StatefulWidget {
  final CaseModel clientCase;
  const EditCaseScreen({
    super.key,
    required this.clientCase,
  });

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  late EditCaseViewModel editCaseVM;
  @override
  void initState() {
    super.initState();

    final editCaseVM = Provider.of<EditCaseViewModel>(context, listen: false);
    editCaseVM.initializeFields(widget.clientCase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Case'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: Consumer<EditCaseViewModel>(
        builder: (context, editCaseVM, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField.fieldLabel('Enter Case Title *'),
                  CustomTextField(controller: editCaseVM.titleController),
                  SizedBox(
                    height: 12.h,
                  ),
                  CustomTextField.fieldLabel('Enter Case Description'),
                  CustomTextField(controller: editCaseVM.descController),
                  SizedBox(
                    height: 12.h,
                  ),
                  CustomTextField.fieldLabel('Enter Case Client ID'),
                  CustomTextField(controller: editCaseVM.clientIdController),
                  SizedBox(
                    height: 12.h,
                  ),
                  CustomTextField.fieldLabel('Enter Case Status'),
                  CustomTextField(controller: editCaseVM.statusController),
                  SizedBox(height: 20.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      editCaseVM.saveChanges(context);
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Changes',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
