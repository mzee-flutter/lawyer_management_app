// lib/view/cases_screen_view/hearing_update_screen_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_update_view_model.dart';

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

  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);

  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);

  static const successSurface = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);
  static const successText = Color(0xFF166534);

  static const infoSurface = Color(0xFFEFF6FF);
  static const infoBorder = Color(0xFFBFDBFE);
  static const infoText = Color(0xFF1E40AF);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  // Status colour config
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'adjourned':
        return warningText;
      case 'completed':
        return successText;
      case 'cancelled':
        return danger;
      default:
        return infoText;
    }
  }

  static Color statusSurface(String status) {
    switch (status.toLowerCase()) {
      case 'adjourned':
        return warningSurface;
      case 'completed':
        return successSurface;
      case 'cancelled':
        return dangerSurface;
      default:
        return infoSurface;
    }
  }

  static Color statusBorder(String status) {
    switch (status.toLowerCase()) {
      case 'adjourned':
        return warningBorder;
      case 'completed':
        return successBorder;
      case 'cancelled':
        return dangerBorder;
      default:
        return infoBorder;
    }
  }

  static InputDecoration fieldDecoration(String hint, IconData icon) {
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

class HearingUpdateScreenView extends StatefulWidget {
  final HearingPublicModel hearingData;
  const HearingUpdateScreenView({super.key, required this.hearingData});

  @override
  State<HearingUpdateScreenView> createState() =>
      _HearingUpdateScreenViewState();
}

class _HearingUpdateScreenViewState extends State<HearingUpdateScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HearingUpdateViewModel>();
      vm.resetFields();
      vm.initializeHearingField(widget.hearingData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HearingUpdateViewModel>();
    final listVM = context.read<HearingListViewModel>();

    return Scaffold(
      backgroundColor: _RC.background,
      appBar: AppBar(
        backgroundColor: _RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Hearing',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _RC.textOnDark,
              ),
            ),
            Text(
              widget.hearingData.title,
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current status badge ─────────────────────────
            _CurrentStatusBadge(status: vm.selectedStatus),
            SizedBox(height: 16.h),

            // ── Date picker ───────────────────────────────────
            _SectionLabel('Hearing date'),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: vm.hearingDateTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
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
                  color: _RC.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _RC.divider, width: 0.5),
                  boxShadow: [_RC.card],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 20.sp, color: _RC.navy),
                    SizedBox(width: 12.w),
                    Text(
                      vm.hearingDateTime == null
                          ? 'No date set'
                          : _formatDate(vm.hearingDateTime!),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: _RC.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _RC.navy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // ── Title field ───────────────────────────────────
            _SectionLabel('Hearing title'),
            SizedBox(height: 6.h),
            TextField(
              controller: vm.hearingTitleController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
              decoration: _RC.fieldDecoration(
                'e.g. Evidence — Shah vs. State',
                Icons.gavel_outlined,
              ),
            ),

            SizedBox(height: 16.h),

            // ── Status dropdown ───────────────────────────────
            _SectionLabel('Hearing status'),
            SizedBox(height: 6.h),
            Container(
              decoration: BoxDecoration(
                color: _RC.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _RC.divider, width: 0.5),
                boxShadow: [_RC.card],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: vm.selectedStatus,
                  isExpanded: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  borderRadius: BorderRadius.circular(12.r),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _RC.textSecondary),
                  items: vm.statuses.map((s) {
                    return DropdownMenuItem<String>(
                      value: s,
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: _RC.statusColor(s),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _RC.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) vm.setStatus(value);
                  },
                ),
              ),
            ),

            // ── Adjournment panel — animated, only when adjourned ──
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: vm.isAdjourning
                  ? _AdjournmentPanel(vm: vm)
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: 16.h),

            // ── Notes field ───────────────────────────────────
            _SectionLabel('Notes (optional)'),
            SizedBox(height: 6.h),
            TextField(
              controller: vm.hearingNotesController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
              decoration: _RC.fieldDecoration(
                'Additional context or preparation notes...',
                Icons.notes_outlined,
              ),
            ),

            SizedBox(height: 32.h),

            // ── Save button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        // Validate adjournment reason when adjourning
                        if (vm.isAdjourning &&
                            vm.adjournmentReasonController.text
                                .trim()
                                .isEmpty) {
                          SnakeBars.flutterToast(
                            'Please enter the reason for adjournment',
                            context,
                          );
                          return;
                        }
                        try {
                          final updated = await vm.updateHearing(
                            widget.hearingData.id,
                          );
                          listVM.updateHearing(updated);
                          vm.resetFields();
                          Navigator.pop(context);
                          SnakeBars.flutterToast(
                            'Hearing updated successfully',
                            context,
                          );
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
                child: vm.isLoading
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
                          Icon(Icons.save_outlined,
                              color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Save Hearing',
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

            SizedBox(height: 24.h),
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
}

// ─────────────────────────────────────────────────────────────
// Current status badge — shows at top of screen
// ─────────────────────────────────────────────────────────────
class _CurrentStatusBadge extends StatelessWidget {
  final String status;
  const _CurrentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _RC.statusSurface(status),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _RC.statusBorder(status), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: _RC.statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Current status: ${status[0].toUpperCase()}${status.substring(1)}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: _RC.statusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Adjournment panel — slides in when status = "adjourned"
// ─────────────────────────────────────────────────────────────
class _AdjournmentPanel extends StatelessWidget {
  final HearingUpdateViewModel vm;
  const _AdjournmentPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final todayLabel = '${today.day} ${months[today.month - 1]} ${today.year}';

    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _RC.warningSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _RC.warningBorder, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.schedule_outlined,
                    size: 15.sp, color: _RC.warningText),
                SizedBox(width: 8.w),
                Text(
                  'Adjournment details',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.warningText,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Auto-date label
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _RC.warningBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.today_outlined,
                      size: 15.sp, color: _RC.warningText),
                  SizedBox(width: 8.w),
                  Text(
                    'Adjourned on: $todayLabel',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _RC.warningText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _RC.warningBorder,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Auto',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: _RC.warningText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Reason field
            Text(
              'Reason for adjournment *',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _RC.warningText,
              ),
            ),
            SizedBox(height: 5.h),
            TextField(
              controller: vm.adjournmentReasonController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 13.sp, color: _RC.textPrimary),
              decoration: InputDecoration(
                hintText:
                    'e.g. Counsel unavailable, Judge on leave, Witness absent...',
                hintStyle: TextStyle(color: _RC.textTertiary, fontSize: 12.sp),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: _RC.warningBorder, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: _RC.warningBorder, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: _RC.warningText, width: 1.5),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Info note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 12.sp, color: _RC.warningText),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'This will be recorded in the adjournment history '
                    'and visible on the calendar.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _RC.warningText.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared label widget
// ─────────────────────────────────────────────────────────────
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
