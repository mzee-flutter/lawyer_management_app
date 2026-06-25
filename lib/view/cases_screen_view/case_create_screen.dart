import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_dropdown_form_field.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_stage_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_status_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';

import '../../resources/court_type_dropdown_field.dart';

class CaseCreateScreen extends StatelessWidget {
  const CaseCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseCreateVM = context.watch<CaseCreateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Case"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 10.h,
        ),
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
                caseCreateVM.registrationDate == null
                    ? "Select Registration Date"
                    : caseCreateVM.registrationDate.toString().split(" ").first,
              ),
              trailing: Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                caseCreateVM.setRegistrationDate(date);
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels('Enter Case Number'),
            _buildTextField(caseCreateVM.caseNumberController),
            SizedBox(height: 12.h),

            _buildLabels("First Party Name*"),
            _buildTextField(caseCreateVM.firstPartyNameController),
            SizedBox(height: 12.h),

            SizedBox(height: 12.h),
            _buildLabels("Opposite Party Name"),
            _buildTextField(caseCreateVM.oppositePartyNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Type*"),
            Consumer<CaseTypeViewModel>(
              builder:
                  (BuildContext context, CaseTypeViewModel caseTypeVM, child) {
                return CustomDropdownFormField(
                  label: "Select Case Type",
                  items: caseTypeVM.items,
                  getId: (item) => item.id,
                  getLabel: (item) => item.name,
                  onSelected: (String id) {
                    caseTypeVM.selectItem(
                      id,
                      caseTypeVM.items.firstWhere((type) => type.id == id).name,
                    );
                  },
                  viewModel: caseTypeVM,
                );
              },
            ),
            SizedBox(height: 12.h),

            // Notes
            _buildLabels("Enter Case Notes"),
            _buildTextField(
              caseCreateVM.caseNotesController,
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
            _buildLabels("Court Category*"),

            CourtTypeDropdownField(
              label: "Select court category",
              onSelected: (id) {
                context.read<CourtTypeViewModel>().selectedCourtId = id;
              },
            ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: caseCreateVM.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: caseCreateVM.judgeNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Stage"),
            Consumer<CaseStageViewModel>(
              builder: (BuildContext context, caseStageVM, child) {
                return CustomDropdownFormField(
                  label: "Case Stage",
                  items: caseStageVM.items,
                  getId: (item) => item.id,
                  getLabel: (item) => item.name,
                  onSelected: (String id) {
                    caseStageVM.selectItem(
                      id,
                      caseStageVM.items
                          .firstWhere((stage) => stage.id == id)
                          .name,
                    );
                  },
                  viewModel: caseStageVM,
                );
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels("Case Status"),
            Consumer<CaseStatusViewModel>(
                builder: (BuildContext context, caseStatusVM, child) {
              return CustomDropdownFormField(
                label: "Case Status",
                items: caseStatusVM.items,
                getId: (item) => item.id,
                getLabel: (item) => item.name,
                onSelected: (String id) {
                  caseStatusVM.selectItem(
                    id,
                    caseStatusVM.items
                        .firstWhere((status) => status.id == id)
                        .name,
                  );
                },
                viewModel: caseStatusVM,
              );
            }),
            SizedBox(height: 12.h),

            _buildLabels("Enter Legal Fee"),
            _buildTextField(caseCreateVM.legalFeesController),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: caseCreateVM.loading
                  ? null
                  : () async {
                      try {
                        final caseStatusVM =
                            context.read<CaseStatusViewModel>();
                        final caseStageVM = context.read<CaseStageViewModel>();
                        final caseTypeVM = context.read<CaseTypeViewModel>();
                        final courtCategoryVM =
                            context.read<CourtTypeViewModel>();
                        if (courtCategoryVM.selectedCourtId == null ||
                            caseTypeVM.selectedId == null ||
                            caseStageVM.selectedId == null ||
                            caseStatusVM.selectedId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please select all dropdown fields"),
                            ),
                          );
                          return;
                        }

                        final dbCase = await context
                            .read<CaseCreateViewModel>()
                            .createCase(
                              context: context,
                              courtCategoryId: courtCategoryVM.selectedCourtId!,
                              caseTypeId: caseTypeVM.selectedId!,
                              caseStageId: caseStageVM.selectedId!,
                              caseStatusId: caseStatusVM.selectedId!,
                            );
                        context.read<CaseListViewModel>().addCase(dbCase);

                        caseCreateVM.resetForm();
                        caseTypeVM.reset();
                        caseStageVM.reset();
                        caseStatusVM.reset();
                        courtCategoryVM.reset();

                        Navigator.pop(context);
                        SnakeBars.flutterToast(
                            "Case created successfully", context);
                      } catch (e) {
                        SnakeBars.flutterToast(
                            "Failed to create case", context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: caseCreateVM.loading
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
}
