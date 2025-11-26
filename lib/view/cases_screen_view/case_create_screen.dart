// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:right_case/resources/custom_text_fields.dart';
// import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
//
// class CaseCreateScreen extends StatefulWidget {
//   const CaseCreateScreen({super.key});
//
//   @override
//   State<CaseCreateScreen> createState() => _CaseCreateScreenState();
// }
//
// class _CaseCreateScreenState extends State<CaseCreateScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Case"),
//         backgroundColor: Colors.grey.shade300,
//       ),
//       body: Consumer<CaseCreateViewModel>(
//         builder: (context, caseCreateVM, child) {
//           return Padding(
//             padding: EdgeInsets.all(16.0.r),
//             child: ListView(
//               children: [
//                 CustomTextField.fieldLabel('Enter Case Title'),
//                 CustomTextField(controller: caseCreateVM.titleController),
//                 SizedBox(height: 12.h),
//                 CustomTextField.fieldLabel('Enter Case Description'),
//                 CustomTextField(controller: caseCreateVM.descController),
//                 SizedBox(height: 12.h),
//                 CustomTextField.fieldLabel('Enter Client ID'),
//                 CustomTextField(controller: caseCreateVM.clientIdController),
//                 SizedBox(height: 12.h),
//                 CustomTextField.fieldLabel('Select Case Status'),
//                 DropdownButtonFormField<String>(
//                   focusColor: Colors.grey.shade300,
//                   dropdownColor: Colors.grey.shade300,
//                   value: caseCreateVM.statusController.text.isNotEmpty
//                       ? caseCreateVM.statusController.text
//                       : null,
//                   items: [
//                     'None',
//                     'Running',
//                     'Decided',
//                     'Date Awaited',
//                     'Abandoned'
//                   ]
//                       .map((status) => DropdownMenuItem(
//                             value: status == 'None' ? '' : status,
//                             child: Text(status),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       caseCreateVM.statusController.text = value;
//                     }
//                   },
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     caseCreateVM.submitCase(context);
//                     caseCreateVM.clearFields();
//                   },
//                   icon: const Icon(Icons.cases_rounded, color: Colors.white),
//                   label: const Text(
//                     'Add Case',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade800,
//                     minimumSize: const Size(double.infinity, 48),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';

class CaseCreateScreen extends StatelessWidget {
  const CaseCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CaseCreateViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Case"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabels("Enter Registration Date"),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              tileColor: Colors.grey.shade300,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              title: Text(
                vm.registrationDate == null
                    ? "Select Registration Date"
                    : vm.registrationDate.toString().split(" ").first,
              ),
              trailing: Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  vm.registrationDate = date;
                  vm.notifyListeners();
                }
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels('Enter Case Number'),
            _buildTextField(vm.caseNumberController),
            SizedBox(height: 12.h),

            _buildLabels("First Party"),
            _customDropDownButtonFormField(
              (value) => vm.firstPartyId = value.toString(),
            ),
            SizedBox(height: 12.h),

            _buildLabels("Opposite Party"),
            _customDropDownButtonFormField(
              (value) => vm.secondPartyId = value.toString(),
            ),

            SizedBox(height: 12.h),
            _buildLabels("Opposite Party Name"),
            _buildTextField(vm.oppositePartyNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Type*"),
            _customDropDownButtonFormField((value) => {}),
            SizedBox(height: 12.h),

            // Notes
            _buildLabels("Enter Case Notes"),
            _buildTextField(
              vm.caseNotesController,
              maxLines: 3,
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(child: Divider(endIndent: 5.w)),
                Text(
                  "Court Detail",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                Expanded(child: Divider(indent: 5.w))
              ],
            ),

            _buildLabels("Court Category"),
            _customDropDownButtonFormField(
              (value) => vm.courtCategoryId = value.toString(),
            ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: vm.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: vm.judgeNameController),
            SizedBox(height: 12.h),

            // Case Stage
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Case Stage"),
              items: [],
              onChanged: (val) => vm.caseStageId = val.toString(),
            ),

            // Case Status
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Case Status"),
              items: [],
              onChanged: (val) => vm.caseStatusId = val.toString(),
            ),

            // Legal Fees
            SizedBox(height: 12.h),
            CustomTextField.fieldLabel('Enter Legal Fee'),
            CustomTextField(controller: vm.legalFeesController),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: vm.loading
                  ? null // disable button when loading
                  : () async {
                      await vm.createCase(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: vm.loading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add_alt, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add Case',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ],
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
            borderRadius: BorderRadius.circular(8.r),
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

  Widget _customDropDownButtonFormField(
      void Function(dynamic newValue) onChange) {
    return DropdownButtonFormField(
        iconDisabledColor: Colors.grey.shade900,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade300,
          filled: true,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
        ),
        items: [],
        onChanged: onChange);
  }
}
