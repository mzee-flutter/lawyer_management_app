import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/court_type_dropdown_field.dart';
import 'package:right_case/resources/custom_dropdown_form_field.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_stage_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_status_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';

class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static InputDecoration field(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _RC.textTertiary, fontSize: 13.sp),
      prefixIcon: Icon(icon, size: 18.sp, color: _RC.textSecondary),
      filled: true,
      fillColor: _RC.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _RC.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _RC.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _RC.navy, width: 1.5),
      ),
    );
  }
}

class CaseCreateScreen extends StatelessWidget {
  const CaseCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CaseCreateViewModel>();

    return Scaffold(
      backgroundColor: _RC.background,
      appBar: AppBar(
        backgroundColor: _RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Case',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Text('Create a new legal case',
                style: TextStyle(fontSize: 11.sp, color: Colors.white54)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Basic Information ──────────────
            _Section(
              title: 'Basic Information',
              icon: Icons.info_outline,
              children: [
                _Label('Registration date'),
                SizedBox(height: 5.h),
                _DatePickerTile(
                  value: vm.registrationDate,
                  onPick: vm.setRegistrationDate,
                ),
                SizedBox(height: 12.h),
                _Label('Case number'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.caseNumberController,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration: _RC.field('e.g. 2025/HC/001', Icons.tag),
                ),
                SizedBox(height: 12.h),
                _Label('First party name *'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.firstPartyNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration: _RC.field(
                      'Plaintiff / Petitioner name', Icons.person_outline),
                ),
                SizedBox(height: 12.h),
                _Label('Opposite party name'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.oppositePartyNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration: _RC.field(
                      'Defendant / Respondent name', Icons.person_outline),
                ),
                SizedBox(height: 12.h),
                _Label('Case type *'),
                SizedBox(height: 5.h),
                Consumer<CaseTypeViewModel>(
                  builder: (_, typeVM, __) => CustomDropdownFormField(
                    label: 'Select case type',
                    items: typeVM.items,
                    getId: (i) => i.id,
                    getLabel: (i) => i.name,
                    onSelected: (id) => typeVM.selectItem(
                      id,
                      typeVM.items.firstWhere((t) => t.id == id).name,
                    ),
                    viewModel: typeVM,
                  ),
                ),
                SizedBox(height: 12.h),
                _Label('Case notes'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.caseNotesController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration: _RC.field(
                      'Background, context, important details…',
                      Icons.notes_outlined),
                ),
              ],
            ),

            // ── Section 2: Court Details ──────────────────
            _Section(
              title: 'Court Details',
              icon: Icons.account_balance_outlined,
              children: [
                _Label('Court category *'),
                SizedBox(height: 5.h),
                CourtTypeDropdownField(
                  label: 'Select court category',
                  onSelected: (id) {
                    context.read<CourtTypeViewModel>().selectedCourtId = id;
                  },
                ),
                SizedBox(height: 12.h),
                _Label('Court name'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.courtNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration: _RC.field('e.g. Peshawar High Court',
                      Icons.account_balance_outlined),
                ),
                SizedBox(height: 12.h),
                _Label('Judge name'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.judgeNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration:
                      _RC.field('e.g. Justice A. Malik', Icons.gavel_outlined),
                ),
              ],
            ),

            // ── Section 3: Case Settings ──────────────────
            _Section(
              title: 'Case Settings',
              icon: Icons.tune_outlined,
              children: [
                _Label('Case stage'),
                SizedBox(height: 5.h),
                Consumer<CaseStageViewModel>(
                  builder: (_, stageVM, __) => CustomDropdownFormField(
                    label: 'Select case stage',
                    items: stageVM.items,
                    getId: (i) => i.id,
                    getLabel: (i) => i.name,
                    onSelected: (id) => stageVM.selectItem(
                      id,
                      stageVM.items.firstWhere((s) => s.id == id).name,
                    ),
                    viewModel: stageVM,
                  ),
                ),
                SizedBox(height: 12.h),
                _Label('Case status'),
                SizedBox(height: 5.h),
                Consumer<CaseStatusViewModel>(
                  builder: (_, statusVM, __) => CustomDropdownFormField(
                    label: 'Select case status',
                    items: statusVM.items,
                    getId: (i) => i.id,
                    getLabel: (i) => i.name,
                    onSelected: (id) => statusVM.selectItem(
                      id,
                      statusVM.items.firstWhere((s) => s.id == id).name,
                    ),
                    viewModel: statusVM,
                  ),
                ),
                SizedBox(height: 12.h),
                _Label('Legal fees (PKR)'),
                SizedBox(height: 5.h),
                TextField(
                  controller: vm.legalFeesController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
                  decoration:
                      _RC.field('Enter amount', Icons.payments_outlined),
                ),
              ],
            ),

            // ── Submit button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.loading
                    ? null
                    : () async {
                        final typeVM = context.read<CaseTypeViewModel>();
                        final stageVM = context.read<CaseStageViewModel>();
                        final statusVM = context.read<CaseStatusViewModel>();
                        final courtVM = context.read<CourtTypeViewModel>();

                        if (courtVM.selectedCourtId == null ||
                            typeVM.selectedId == null ||
                            stageVM.selectedId == null ||
                            statusVM.selectedId == null) {
                          SnakeBars.flutterToast(
                              'Please complete all required fields', context);
                          return;
                        }

                        try {
                          final dbCase = await vm.createCase(
                            context: context,
                            courtCategoryId: courtVM.selectedCourtId!,
                            caseTypeId: typeVM.selectedId!,
                            caseStageId: stageVM.selectedId!,
                            caseStatusId: statusVM.selectedId!,
                          );
                          context.read<CaseListViewModel>().addCase(dbCase);
                          vm.resetForm();
                          typeVM.reset();
                          stageVM.reset();
                          statusVM.reset();
                          courtVM.reset();
                          Navigator.pop(context);
                          SnakeBars.flutterToast(
                              'Case created successfully', context);
                        } catch (_) {
                          SnakeBars.flutterToast(
                              'Failed to create case', context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _RC.navy,
                  disabledBackgroundColor: _RC.navy.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: vm.loading
                    ? SizedBox(
                        height: 18.h,
                        width: 18.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cases_outlined,
                              color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('Create Case',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ── Shared form widgets ──────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _RC.navy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
              border: Border(
                bottom: BorderSide(color: _RC.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: _RC.navy),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.navy,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: _RC.textSecondary),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? value;
  final void Function(DateTime?) onPick;

  const _DatePickerTile({required this.value, required this.onPick});

  String _fmt(DateTime d) {
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${wd[d.weekday - 1]}, ${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (_, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF1A2744)),
            ),
            child: child!,
          ),
        );
        onPick(picked);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: _RC.background,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: value != null ? _RC.navy : _RC.divider,
            width: value != null ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 18.sp,
              color: value != null ? _RC.navy : _RC.textSecondary,
            ),
            SizedBox(width: 10.w),
            Text(
              value == null ? 'Select date' : _fmt(value!),
              style: TextStyle(
                fontSize: 13.sp,
                color: value != null ? _RC.textPrimary : _RC.textTertiary,
                fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
