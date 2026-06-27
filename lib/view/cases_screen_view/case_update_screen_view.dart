import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/court_type_dropdown_field.dart';
import 'package:right_case/resources/custom_dropdown_form_field.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_stage_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_status_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_update_view_model.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';

class CaseUpdateScreenView extends StatefulWidget {
  final CaseModel caseData;
  const CaseUpdateScreenView({
    super.key,
    required this.caseData,
  });
  @override
  State<CaseUpdateScreenView> createState() => CaseUpdateScreenViewState();
}

class CaseUpdateScreenViewState extends State<CaseUpdateScreenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final caseUpdateVM = context.read<CaseUpdateViewModel>();
      final courtVM = context.read<CourtTypeViewModel>();
      final caseTypeVM = context.read<CaseTypeViewModel>();
      final caseStageVM = context.read<CaseStageViewModel>();
      final caseStatusVM = context.read<CaseStatusViewModel>();

      // ── 1. Hard-reset every VM so stale state from a previous edit
      //       never bleeds into this screen.
      courtVM.reset();
      caseTypeVM.reset();
      caseStageVM.reset();
      caseStatusVM.reset();

      // ── 2. Fill text controllers immediately (sync, no flicker).
      caseUpdateVM.initializeCaseFields(widget.caseData);

      // ── 3. FIX: Show the court category name RIGHT NOW so the field is
      //       never blank while the network fetch is in-flight.
      //       Step 5 will overwrite this with the precise depth selection.
      final cat = widget.caseData.courtCategory;
      if (cat != null) courtVM.selectCourtType(cat.id, cat.name);

      // ── 4. Parallel fetch — court data guard skips if already cached.
      await Future.wait([
        courtVM.fetchCourtType(),
        caseTypeVM.fetchItems(),
        caseStageVM.fetchItems(),
        caseStatusVM.fetchItems(),
      ]);

      if (!mounted) return;

      // ── 5. Depth-aware court pre-selection now that the full tree is
      //       available.  selectSubSubCategoryById / selectSubCategoryById
      //       both set ALL ancestor IDs internally, so the overlay's
      //       lineage tracer will expand every parent folder correctly.
      if (cat != null) {
        if (cat.parentId == null) {
          // Layer 1 – root court
          courtVM.selectCourtType(cat.id, cat.name);
        } else {
          final parent =
              courtVM.courtType.firstWhereOrNull((e) => e.id == cat.parentId);

          if (parent != null && parent.parentId == null) {
            // Layer 2 – sub-category
            courtVM.selectSubCategoryById(cat.id);
          } else if (parent != null && parent.parentId != null) {
            // Layer 3 – sub-sub-category
            courtVM.selectSubSubCategoryById(cat.id);
          }
        }
      }

      // ── 6. Pre-select the remaining dropdowns.
      caseTypeVM.trySelectById(widget.caseData.caseTypeId);
      caseStageVM.trySelectById(widget.caseData.caseStageId);
      caseStatusVM.trySelectById(widget.caseData.caseStatusId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final caseUpdateVM = context.watch<CaseUpdateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Case"),
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
                caseUpdateVM.registrationDate == null
                    ? "Select Registration Date"
                    : caseUpdateVM.registrationDate.toString().split(" ").first,
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
                  caseUpdateVM.setRegistrationDate(date);
                }
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels('Enter Case Number'),
            _buildTextField(caseUpdateVM.caseNumberController),
            SizedBox(height: 12.h),

            _buildLabels("First Party Name"),
            _buildTextField(caseUpdateVM.firstPartyNameController),
            SizedBox(height: 12.h),

            SizedBox(height: 12.h),
            _buildLabels("Opposite Party Name"),
            _buildTextField(caseUpdateVM.oppositePartyNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Type"),
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
            _buildTextField(caseUpdateVM.caseNotesController, maxLines: 3),
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
            CourtTypeDropdownField(
              label: "Select court category",
              onSelected: (_) {},
            ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: caseUpdateVM.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: caseUpdateVM.judgeNameController),
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
            _buildTextField(caseUpdateVM.legalFeesController),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: caseUpdateVM.isLoading
                  ? null
                  : () async {
                      try {
                        final caseUpdateVM =
                            context.read<CaseUpdateViewModel>();
                        final caseStatusVM =
                            context.read<CaseStatusViewModel>();
                        final caseStageVM = context.read<CaseStageViewModel>();
                        final caseTypeVM = context.read<CaseTypeViewModel>();
                        final courtCategoryVM =
                            context.read<CourtTypeViewModel>();

                        final dbCase = await caseUpdateVM.saveCase(
                          context: context,
                          courtCategoryId:
                              courtCategoryVM.selectedSubSubCourtId ??
                                  courtCategoryVM.selectedSubCourtId ??
                                  courtCategoryVM.selectedCourtId!,
                          caseTypeId: caseTypeVM.selectedId!,
                          caseStageId: caseStageVM.selectedId!,
                          caseStatusId: caseStatusVM.selectedId!,
                          id: widget.caseData.id,
                        );
                        context.read<CaseListViewModel>().updateCase(dbCase);

                        caseUpdateVM.resetForm();
                        caseTypeVM.reset();
                        caseStageVM.reset();
                        caseStatusVM.reset();
                        courtCategoryVM.reset();

                        SnakeBars.flutterToast(
                            "Case updated successfully", context);
                        Navigator.pop(context);
                      } catch (e) {
                        SnakeBars.flutterToast("Failed to update", context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: caseUpdateVM.isLoading
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
                          'Save Case',
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
