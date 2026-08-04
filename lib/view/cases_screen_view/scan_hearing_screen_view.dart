import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/case_detail_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/legal_task_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/scan_hearing_view_model.dart';

/// Full-screen "Scan Court Document" flow:
///   1. Camera capture
///   2. Upload + vision extraction (progress)
///   3. Confirmation form — every extracted field is editable/overridable
///      before anything gets scheduled
///
/// Entry point is intentionally global (not tied to a pre-opened case) so
/// the lawyer can scan a document and let the app find the right case,
/// per the matching requirement this feature was built around.
class ScanHearingScreenView extends StatelessWidget {
  const ScanHearingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanHearingViewModel>();

    return Scaffold(
      backgroundColor: RC.surface,
      appBar: AppBar(
        backgroundColor: RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Court Document',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: RC.textOnDark,
              ),
            ),
            Text(
              'Schedule from an order sheet or notice',
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: SafeArea(child: _buildBody(context, vm)),
    );
  }

  Widget _buildBody(BuildContext context, ScanHearingViewModel vm) {
    if (vm.extraction != null) {
      return _ConfirmationForm(vm: vm);
    }

    switch (vm.status) {
      case ScanStatus.uploading:
        return _UploadingView(progress: vm.uploadProgress);
      default:
        return _CapturePrompt(vm: vm);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// STAGE 1 — Capture prompt
// ─────────────────────────────────────────────────────────────
class _CapturePrompt extends StatelessWidget {
  final ScanHearingViewModel vm;
  const _CapturePrompt({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              color: RC.navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.document_scanner_outlined,
                size: 44.sp, color: RC.navy),
          ),
          SizedBox(height: 24.h),
          Text(
            'Scan the order sheet or\nnext-hearing notice',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Make sure the case number and hearing date are clearly '
            'visible and in focus before you capture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: RC.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          if (vm.error != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: RC.dangerSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: RC.dangerBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16.sp, color: RC.danger),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      vm.error!,
                      style: TextStyle(fontSize: 12.sp, color: RC.danger),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.status == ScanStatus.capturing
                  ? null
                  : () => vm.captureFromCamera(),
              style: ElevatedButton.styleFrom(
                backgroundColor: RC.navy,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: vm.status == ScanStatus.capturing
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
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Open Camera',
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAGE 2 — Uploading / reading
// ─────────────────────────────────────────────────────────────
class _UploadingView extends StatelessWidget {
  final double progress;
  const _UploadingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final stillUploading = progress < 0.999;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: CircularProgressIndicator(
                value: stillUploading ? progress : null,
                color: RC.navy,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              stillUploading ? 'Uploading photo...' : 'Reading document...',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: RC.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              stillUploading
                  ? '${(progress * 100).round()}%'
                  : 'This can take a few seconds.',
              style: TextStyle(fontSize: 12.sp, color: RC.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAGE 3 — Confirmation form
// ─────────────────────────────────────────────────────────────
class _ConfirmationForm extends StatelessWidget {
  final ScanHearingViewModel vm;
  const _ConfirmationForm({required this.vm});

  @override
  Widget build(BuildContext context) {
    final extraction = vm.extraction!;
    final confirming = vm.status == ScanStatus.confirming;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _confidenceBadge(extraction.extractionConfidence),
          SizedBox(height: 14.h),
          if (extraction.extractedCourtName != null ||
              extraction.extractedJudgeName != null)
            _readOnlyInfoCard(extraction),
          if (extraction.extractedCourtName != null ||
              extraction.extractedJudgeName != null)
            SizedBox(height: 14.h),
          _SectionLabel('Case'),
          SizedBox(height: 6.h),
          _caseMatchSection(context),
          SizedBox(height: 16.h),
          _SectionLabel('Hearing date'),
          SizedBox(height: 6.h),
          _datePicker(context),
          SizedBox(height: 10.h),
          _timeSection(context),
          SizedBox(height: 16.h),
          _SectionLabel('Notes (optional)'),
          SizedBox(height: 6.h),
          TextField(
            controller: vm.notesController,
            maxLines: 3,
            style: TextStyle(fontSize: 13.sp, color: RC.textPrimary),
            decoration:
                _fieldDecoration('Additional context...', Icons.notes_outlined),
          ),
          SizedBox(height: 24.h),
          if (vm.error != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 14.h),
              decoration: BoxDecoration(
                color: RC.dangerSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: RC.dangerBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16.sp, color: RC.danger),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(vm.error!,
                        style: TextStyle(fontSize: 12.sp, color: RC.danger)),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: confirming || extraction.matchStatus == 'unmatched'
                  ? null
                  : () => _onConfirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: RC.navy,
                disabledBackgroundColor: RC.navy.withValues(alpha: 0.4),
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: confirming
                  ? SizedBox(
                      height: 18.h,
                      width: 18.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Confirm & Schedule',
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
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: confirming ? null : () => vm.retake(),
                icon: Icon(Icons.replay, size: 16.sp, color: RC.textSecondary),
                label: Text('Retake',
                    style: TextStyle(fontSize: 12.sp, color: RC.textSecondary)),
              ),
              TextButton.icon(
                onPressed: confirming
                    ? null
                    : () async {
                        await vm.discardCurrentScan();
                        if (context.mounted) Navigator.pop(context);
                      },
                icon: Icon(Icons.delete_outline, size: 16.sp, color: RC.danger),
                label: Text('Discard',
                    style: TextStyle(fontSize: 12.sp, color: RC.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    final vm = context.read<ScanHearingViewModel>();
    final hearing = await vm.confirmAndCreateHearing();
    if (hearing == null || !context.mounted) return;

    // Mirrors the auto-task-creation side effect from manual hearing
    // creation (HearingCreateScreenView) — a scanned hearing should get
    // the same automatic prep task as a manually-added one.
    try {
      await context.read<LegalTaskViewModel>().createAutoTask(
            caseId: hearing.caseId,
            hearingId: hearing.id,
            hearingDateTime: hearing.hearingDateTime,
            caseTitle: vm.selectedCaseDisplayTitle,
          );
    } catch (_) {
      // Non-fatal — the hearing itself was created successfully either way.
    }

    if (!context.mounted) return;
    SnakeBars.flutterToast('Hearing scheduled successfully', context);
    Navigator.pop(context, hearing);
  }

  Widget _confidenceBadge(String confidence) {
    late final Color surface, text;
    late final String label;
    late final IconData icon;
    switch (confidence) {
      case 'high':
        surface = RC.successSurface;
        text = RC.successText;
        label = 'High confidence extraction';
        icon = Icons.verified_outlined;
        break;
      case 'medium':
        surface = RC.warningSurface;
        text = RC.warningText;
        label = 'Medium confidence — please double check the fields below';
        icon = Icons.warning_amber_outlined;
        break;
      default:
        surface = RC.dangerSurface;
        text = RC.danger;
        label = 'Low confidence — this document was hard to read, please '
            'verify everything carefully';
        icon = Icons.report_gmailerrorred_outlined;
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: text),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.sp, color: text, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyInfoCard(extraction) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: RC.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (extraction.extractedCourtName != null)
            _infoRow(Icons.account_balance_outlined, 'Court',
                extraction.extractedCourtName!),
          if (extraction.extractedCourtName != null &&
              extraction.extractedJudgeName != null)
            SizedBox(height: 6.h),
          if (extraction.extractedJudgeName != null)
            _infoRow(
                Icons.person_outline, 'Judge', extraction.extractedJudgeName!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: RC.textSecondary),
        SizedBox(width: 8.w),
        Text('$label: ',
            style: TextStyle(
                fontSize: 12.sp,
                color: RC.textSecondary,
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 12.sp, color: RC.textPrimary)),
        ),
      ],
    );
  }

  Widget _caseMatchSection(BuildContext context) {
    final vm = context.watch<ScanHearingViewModel>();
    final extraction = vm.extraction!;

    if (extraction.matchStatus == 'unmatched') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: RC.dangerSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: RC.dangerBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.search_off, size: 16.sp, color: RC.danger),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "We couldn't match this to any of your cases"
                '${extraction.extractedCaseNumber != null ? " (read as \"${extraction.extractedCaseNumber}\")" : ""}. '
                'Please verify the case number on the document, or add this '
                "hearing from that case's detail screen instead.",
                style:
                    TextStyle(fontSize: 12.sp, color: RC.danger, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    final options = vm.selectableCases;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: RC.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.divider, width: 0.5),
      ),
      child: Column(
        children: [
          if (extraction.matchStatus == 'ambiguous')
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 4.h),
              child: Row(
                children: [
                  Icon(Icons.rule, size: 14.sp, color: RC.warningText),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'A few possible matches — please pick the right one',
                      style: TextStyle(
                          fontSize: 11.5.sp,
                          color: RC.warningText,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          for (final option in options)
            RadioGroup(
              groupValue: vm.selectedCaseId,
              onChanged: (id) => vm.selectCase(id!),
              child: RadioListTile<String>(
                value: option.caseId,
                // groupValue:vm.selectedCaseId,
                // onChanged: (id) => vm.selectCase(id!),
                activeColor: RC.navy,
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                title: Text(
                  option.displayTitle,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: RC.textPrimary),
                ),
                subtitle: Text(
                  option.caseNumber,
                  style: TextStyle(fontSize: 11.sp, color: RC.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    final vm = context.watch<ScanHearingViewModel>();
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: vm.hearingDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (_, child) => Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: RC.navy)),
            child: child!,
          ),
        );
        if (picked != null) vm.setHearingDate(picked);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: RC.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: vm.hearingDate != null ? RC.navy : RC.divider,
            width: vm.hearingDate != null ? 1.5 : 0.5,
          ),
          boxShadow: [RC.card],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 20.sp,
                color: vm.hearingDate != null ? RC.navy : RC.textSecondary),
            SizedBox(width: 12.w),
            Text(
              vm.hearingDate == null
                  ? 'Select hearing date'
                  : _formatDate(vm.hearingDate!),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: vm.hearingDate != null
                    ? FontWeight.w500
                    : FontWeight.normal,
                color:
                    vm.hearingDate != null ? RC.textPrimary : RC.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeSection(BuildContext context) {
    final vm = context.watch<ScanHearingViewModel>();
    if (!vm.hasSpecificTime) {
      return GestureDetector(
        onTap: vm.hearingDate == null
            ? null
            : () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (_, child) => Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: RC.navy)),
                    child: child!,
                  ),
                );
                if (picked != null) vm.setHearingTime(picked);
              },
        child: Row(
          children: [
            Icon(Icons.access_time, size: 15.sp, color: RC.textSecondary),
            SizedBox(width: 6.w),
            Text(
              'Add a specific time (optional)',
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    vm.hearingDate == null ? RC.textTertiary : RC.textSecondary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: RC.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RC.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16.sp, color: RC.gold),
          SizedBox(width: 8.w),
          Text(
            _formatTime(vm.hearingTime!),
            style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: RC.textPrimary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => vm.setHearingTime(null),
            child: Text('Remove',
                style: TextStyle(fontSize: 11.sp, color: RC.textSecondary)),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: RC.textTertiary, fontSize: 13.sp),
      prefixIcon: Icon(icon, size: 18.sp, color: RC.textSecondary),
      filled: true,
      fillColor: RC.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: RC.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: RC.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: RC.navy, width: 1.5),
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

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
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
        color: RC.textSecondary,
      ),
    );
  }
}
