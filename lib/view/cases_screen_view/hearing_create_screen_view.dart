import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';

// ── Design tokens ─────────────────────────────────────────────
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
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  static InputDecoration fieldDecoration(
      String hint, IconData icon, BuildContext context) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _RC.textTertiary, fontSize: 13.sp),
      prefixIcon: Icon(icon, size: 18.sp, color: _RC.textSecondary),
      filled: true,
      fillColor: _RC.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: _RC.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: _RC.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: _RC.navy, width: 1.5),
      ),
    );
  }
}

class HearingCreateScreenView extends StatelessWidget {
  final String caseId;
  const HearingCreateScreenView({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HearingCreateViewModel>();
    final hearingListVM = context.read<HearingListViewModel>();

    return Scaffold(
      backgroundColor: _RC.surface,
      appBar: AppBar(
        backgroundColor: _RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Hearing',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _RC.textOnDark,
              ),
            ),
            Text(
              'Schedule a new court hearing',
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date picker card ─────────────────────────────
            _SectionLabel('Hearing date'),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: vm.hearingDateTime ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  builder: (_, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: _RC.navy),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) vm.setHearingDateTime(picked);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: _RC.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: vm.hearingDateTime != null ? _RC.navy : _RC.divider,
                    width: vm.hearingDateTime != null ? 1.5 : 0.5,
                  ),
                  boxShadow: [_RC.card],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20.sp,
                      color: vm.hearingDateTime != null
                          ? _RC.navy
                          : _RC.textSecondary,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      vm.hearingDateTime == null
                          ? 'Select hearing date'
                          : _formatDate(vm.hearingDateTime!),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: vm.hearingDateTime != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: vm.hearingDateTime != null
                            ? _RC.textPrimary
                            : _RC.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (vm.hearingDateTime != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _RC.navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _RC.navy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // ── Optional specific-time affordance ────────────
            // Most hearings are cause-list date entries with no fixed
            // clock time — the lawyer shows up when court opens and waits
            // their turn. This stays optional and off by default, and only
            // surfaces a time when the lawyer explicitly knows one (e.g. a
            // video hearing, tribunal sitting, or a judge-stated time).
            if (!vm.hasSpecificTime)
              GestureDetector(
                onTap: vm.hearingDateTime == null
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (_, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme:
                                  const ColorScheme.light(primary: _RC.navy),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) vm.setHearingTime(picked);
                      },
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 15.sp, color: _RC.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      'Add a specific time (optional)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: vm.hearingDateTime == null
                            ? _RC.textTertiary
                            : _RC.textSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: _RC.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _RC.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _RC.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16.sp, color: _RC.gold),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(vm.hearingDateTime!),
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: _RC.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => vm.setHearingTime(null),
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _RC.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16.h),

            // ── Title field ──────────────────────────────────
            _SectionLabel('Hearing title'),
            SizedBox(height: 6.h),
            TextField(
              controller: vm.hearingTitleController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
              decoration: _RC.fieldDecoration(
                'e.g. Evidence — Shah vs. State',
                Icons.gavel_outlined,
                context,
              ),
            ),

            SizedBox(height: 16.h),

            // ── Notes field ──────────────────────────────────
            _SectionLabel('Notes (optional)'),
            SizedBox(height: 6.h),
            TextField(
              controller: vm.hearingNotesController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
              decoration: _RC.fieldDecoration(
                'Additional context or preparation notes...',
                Icons.notes_outlined,
                context,
              ),
            ),

            SizedBox(height: 32.h),

            // ── Submit button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.loading
                    ? null
                    : () async {
                        if (vm.hearingDateTime == null) {
                          SnakeBars.flutterToast(
                              'Please select a hearing date', context);
                          return;
                        }
                        if (vm.hearingTitleController.text.trim().isEmpty) {
                          SnakeBars.flutterToast(
                              'Please enter a hearing title', context);
                          return;
                        }
                        try {
                          final dbHearing =
                              await vm.createHearing(context, caseId);
                          hearingListVM.addHearingLocally(dbHearing);
                          vm.resetFields();
                          Navigator.pop(context);
                          SnakeBars.flutterToast(
                              'Hearing added successfully', context);
                        } catch (e) {
                          SnakeBars.flutterToast(e.toString(), context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _RC.navy,
                  disabledBackgroundColor: _RC.navy.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: vm.loading
                    ? SizedBox(
                        height: 18.h,
                        width: 18.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_calendar_outlined,
                              color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Add Hearing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$displayH:$m $period';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: _RC.textSecondary,
      ),
    );
  }
}
