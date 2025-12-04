import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_dropdown_form_field.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';

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
              onTap: () {},
              item: [],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Opposite Party"),
            _customDropDownButtonFormField(
              (value) => vm.secondPartyId = value.toString(),
              onTap: () {},
              item: [],
            ),

            SizedBox(height: 12.h),
            _buildLabels("Opposite Party Name"),
            _buildTextField(vm.oppositePartyNameController),
            SizedBox(height: 12.h),

            // inside your column children where you had the case type

            _buildLabels("Case Type*"),
            Consumer<CaseTypeViewModel>(
              builder:
                  (BuildContext context, CaseTypeViewModel caseTypeVM, child) {
                return CustomDropdownFormField(
                  label: "Select Case Type",
                  items: caseTypeVM.caseTypes,
                  getId: (item) => item.id,
                  getLabel: (item) => item.name,
                  onSelected: (String id) {},
                  viewModel: caseTypeVM,
                );
              },
            ),
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
              onTap: () {},
              item: [
                DropdownMenuItem(child: Text("this is the CourtCategory"))
              ],
            ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: vm.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: vm.judgeNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Stage"),
            _customDropDownButtonFormField(
              (value) => vm.caseStageId = value.toString(),
              onTap: () {},
              item: [DropdownMenuItem(child: Text("Cause is the CaseStage"))],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Case Status"),
            _customDropDownButtonFormField(
              (value) => vm.caseStatusId = value.toString(),
              onTap: () {},
              item: [],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Enter Legal Fee"),
            _buildTextField(vm.legalFeesController),

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
    void Function(dynamic newValue) onChange, {
    required void Function()? onTap,
    required List<DropdownMenuItem<dynamic>>? item,
    bool isLoading = false,
  }) {
    return Stack(
      children: [
        DropdownButtonFormField(
          iconDisabledColor: Colors.grey.shade900,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade300,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                8.r,
              ),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
          ),
          items: item,
          onChanged: onChange,
          onTap: onTap,
        ),

        // LOADER OVERLAY INSIDE DROPDOWN FIELD
        if (isLoading)
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 12),
              color: Colors.transparent,
              child: SizedBox(
                height: 20.h,
                width: 20.w,
                child: CupertinoActivityIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
