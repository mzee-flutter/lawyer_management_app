import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/case_resources/case_file_section_view.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/cases_screen_view/case_update_screen_view.dart';
import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/add_case_file_view_model.dart';
import 'package:right_case/view_model/cases_view_model/add_related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_service_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/remove_case_file_view_model.dart';

import '../../resources/case_resources/case_file_upload_sheet.dart';
import '../../resources/case_resources/related_clients_sheet.dart';
import '../../resources/system_design/case_detail_theme.dart';

// ── Wrapper — keeps providers setup exactly as before ────────────
class CaseDetailInfoScreenWrapper extends StatelessWidget {
  final String caseId;
  const CaseDetailInfoScreenWrapper({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CaseFilesViewModel(caseId: caseId)),
        ChangeNotifierProvider(create: (_) => AddCaseFileViewModel()),
        ChangeNotifierProvider(create: (_) => RemoveCaseFileViewModel()),
        ChangeNotifierProvider(create: (_) => CaseFilesServiceViewModel()),
        ChangeNotifierProvider(
            create: (_) => RelatedClientViewModel(caseId: caseId)),
        ChangeNotifierProvider(create: (_) => AddRelatedClientViewModel()),
      ],
      child: CaseDetailInfoScreenView(caseId: caseId),
    );
  }
}

// ── Main screen ──────────────────────────────────────────────────
class CaseDetailInfoScreenView extends StatefulWidget {
  final String caseId;
  const CaseDetailInfoScreenView({super.key, required this.caseId});
  @override
  State<CaseDetailInfoScreenView> createState() =>
      _CaseDetailInfoScreenViewState();
}

class _CaseDetailInfoScreenViewState extends State<CaseDetailInfoScreenView> {
  bool _isUploadSheetOpen = false;
  UploadStatus _lastHandledStatus = UploadStatus.idle;
  late final AddCaseFileViewModel _addFileVM;

  @override
  void initState() {
    super.initState();
    _addFileVM = context.read<AddCaseFileViewModel>();

    // Edge-triggered: only runs when the VM's status actually changes, not
    // on every unrelated rebuild of this screen (e.g. RelatedClientViewModel
    // syncing in the background). This is what makes it reliable instead of
    // a build()-time postFrameCallback, which re-runs its checks on every
    // single rebuild regardless of cause.
    _addFileVM.addListener(_handleUploadStatusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CaseFilesViewModel>().loadFilesFromCase(context);
      final rcVM = context.read<RelatedClientViewModel>();
      rcVM.loadRelatedClientsFromCase(context);
      rcVM.syncUnSyncedClients(context);
    });
  }

  @override
  void dispose() {
    _addFileVM.removeListener(_handleUploadStatusChange);
    super.dispose();
  }

  void _handleUploadStatusChange() {
    if (!mounted) return;
    final status = _addFileVM.status;
    if (status == _lastHandledStatus) return;
    _lastHandledStatus = status;

    switch (status) {
      case UploadStatus.readyToUpload:
        _openUploadSheet();
        break;
      case UploadStatus.success:
        _closeUploadSheet();
        SnakeBars.flutterToast('Files uploaded successfully', context);
        _addFileVM.cancelUploadWorkflow();
        break;
      case UploadStatus.error:
        _closeUploadSheet();
        SnakeBars.flutterToast(_addFileVM.error ?? 'Upload failed', context);
        _addFileVM.cancelUploadWorkflow();
        break;
      case UploadStatus.cancelled:
      case UploadStatus.idle:
        _closeUploadSheet();
        break;
      default:
        break; // picking / uploading: sheet's own Consumer handles the UI
    }
  }

  void _openUploadSheet() {
    if (_isUploadSheetOpen) return;
    _isUploadSheetOpen = true;

    // Completes the instant the sheet's route is gone from the navigator —
    // by any means (Cancel, back press, successful upload). This is the
    // single place _isUploadSheetOpen ever gets cleared, so it can never
    // again get stuck "true" after a back-press.
    showUploadSheet(
      context: context,
      caseId: widget.caseId,
      filesVM: context.read<CaseFilesViewModel>(),
    ).then((_) => _isUploadSheetOpen = false);
  }

  void _closeUploadSheet() {
    if (!_isUploadSheetOpen) return;
    Navigator.of(context).pop();
    // _isUploadSheetOpen is cleared by the .then() in _openUploadSheet
    // above, not here — one flag, one place it gets reset, nothing to fall
    // out of sync.
  }

  @override
  Widget build(BuildContext context) {
    final caseData =
        context.watch<CaseListViewModel>().getCaseById(widget.caseId);

    if (caseData == null) {
      return Scaffold(
        backgroundColor: RC.background,
        appBar: AppBar(
          backgroundColor: RC.navy,
          iconTheme: const IconThemeData(color: Colors.white),
          title:
              const Text('Case Details', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Case not found.')),
      );
    }

    return Scaffold(
      backgroundColor: RC.background,
      appBar: _buildAppBar(context, caseData),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────
            _HeroCard(caseData: caseData),
            SizedBox(height: 12.h),

            // ── Quick actions ──────────────────────────
            _QuickActions(
              caseId: caseData.id,
              onAddFiles: () => _addFileVM.pickFiles(),
              onAddClient: () =>
                  showAddClientsSheet(context: context, caseId: caseData.id),
            ),
            SizedBox(height: 12.h),

            // ── Case information ───────────────────────
            _InfoCard(caseData: caseData),
            SizedBox(height: 12.h),

            // ── Court information ──────────────────────
            _CourtCard(caseData: caseData),
            SizedBox(height: 12.h),

            // ── Case notes (expandable) ────────────────
            if (caseData.caseNotes != null &&
                caseData.caseNotes!.isNotEmpty) ...[
              _NotesCard(notes: caseData.caseNotes!),
              SizedBox(height: 12.h),
            ],

            // ── Files section ──────────────────────────
            _SectionTitle('Case Files'),
            Consumer<CaseFilesViewModel>(
              builder: (_, filesVM, __) =>
                  CaseFilesEmbeddedSection(files: filesVM.files),
            ),
            SizedBox(height: 16.h),

            // ── Timestamps ────────────────────────────
            _TimestampRow(
                label: 'Created',
                value: DateFormat('dd MMM yyyy').format(caseData.createdAt)),
            if (caseData.updatedAt != null)
              _TimestampRow(
                  label: 'Updated',
                  value: DateFormat('dd MMM yyyy').format(caseData.updatedAt!)),
            SizedBox(height: 16.h),

            // ── Related clients ────────────────────────
            Row(
              children: [
                _SectionTitle('Attached Clients'),
                const Spacer(),
                Consumer<RelatedClientViewModel>(
                  builder: (_, rcVM, __) {
                    final hasUnsynced =
                        rcVM.relatedClients.any((rc) => !rc.isSynced);
                    if (!hasUnsynced) return const SizedBox.shrink();
                    return InkWell(
                      onTap: rcVM.isSyncing
                          ? null
                          : () async {
                              final ok =
                                  await rcVM.syncUnSyncedClients(context);
                              if (!context.mounted) return;
                              SnakeBars.flutterToast(
                                ok
                                    ? 'Clients synced'
                                    : rcVM.lastError ?? 'Sync failed',
                                context,
                              );
                            },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: RC.background,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: rcVM.isSyncing
                            ? SizedBox(
                                height: 16.h,
                                width: 16.w,
                                child: CircularProgressIndicator(
                                    color: RC.navy, strokeWidth: 2))
                            : Icon(Icons.refresh, size: 18.sp, color: RC.navy),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Consumer<RelatedClientViewModel>(
              builder: (_, rcVM, __) => RelatedClientsList(
                relatedClients: rcVM.relatedClients,
              ),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CaseModel caseData) {
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Case Details',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(
            '#${caseData.caseNumber}',
            style: TextStyle(fontSize: 11.sp, color: Colors.white54),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaseUpdateScreenView(caseData: caseData),
              ),
            ),
            icon: Icon(Icons.edit_outlined, size: 16.sp, color: RC.gold),
            label: Text('Edit',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: RC.gold,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// ── Hero card ────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final CaseModel caseData;
  const _HeroCard({required this.caseData});

  @override
  Widget build(BuildContext context) {
    final statusName = caseData.caseStatus?.name;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: RC.navy,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [RC.card],
      ),
      child: Column(
        children: [
          // Case number badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Case #${caseData.caseNumber}',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: RC.textOnDarkMuted),
            ),
          ),
          SizedBox(height: 10.h),
          // First party
          Text(
            caseData.firstPartyName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            'vs.',
            style: TextStyle(fontSize: 13.sp, color: RC.textOnDarkMuted),
          ),
          SizedBox(height: 4.h),
          Text(
            caseData.oppositePartyName ?? '—',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: RC.textOnDarkMuted),
          ),
          SizedBox(height: 12.h),
          // Status + type badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (statusName != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: RC.statusSurface(statusName),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: RC.statusColor(statusName)),
                  ),
                ),
              if (caseData.caseType?.name != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    caseData.caseType!.name,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: RC.textOnDarkMuted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final String caseId;
  final VoidCallback onAddFiles;
  final VoidCallback onAddClient;

  const _QuickActions({
    required this.caseId,
    required this.onAddFiles,
    required this.onAddClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.card],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: Icons.event_available_outlined,
            label: 'Hearings',
            color: RC.navy,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HearingListScreenView(caseId: caseId),
              ),
            ),
          ),
          _Divider(),
          _ActionBtn(
            icon: Icons.person_add_outlined,
            label: 'Add Client',
            color: RC.gold,
            onTap: onAddClient,
          ),
          _Divider(),
          _ActionBtn(
            icon: Icons.upload_file_outlined,
            label: 'Add Files',
            color: RC.navy,
            onTap: onAddFiles,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 36.h, width: 0.5, color: RC.divider);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.sp, color: color),
            ),
            SizedBox(height: 5.h),
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: RC.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Case info card ────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final CaseModel caseData;
  const _InfoCard({required this.caseData});

  @override
  Widget build(BuildContext context) {
    final reg = DateFormat('dd MMM yyyy').format(caseData.registrationDate);
    return _DetailSection(
      title: 'Case Information',
      icon: Icons.cases_outlined,
      children: [
        _InfoRow(Icons.calendar_today_outlined, 'Registered', reg),
        _InfoRow(Icons.confirmation_number_outlined, 'Case number',
            caseData.caseNumber),
        if (caseData.caseType != null)
          _InfoRow(
              Icons.category_outlined, 'Case type', caseData.caseType!.name),
        if (caseData.caseStage != null)
          _InfoRow(Icons.layers_outlined, 'Stage', caseData.caseStage!.name),
        if (caseData.caseStatus != null)
          _InfoRow(Icons.flag_outlined, 'Status', caseData.caseStatus!.name),
        if (caseData.legalFees != null)
          _InfoRow(Icons.payments_outlined, 'Legal fees',
              'PKR ${caseData.legalFees!.toStringAsFixed(0)}'),
      ],
    );
  }
}

// ── Court card ────────────────────────────────────────────────────
class _CourtCard extends StatelessWidget {
  final CaseModel caseData;
  const _CourtCard({required this.caseData});

  @override
  Widget build(BuildContext context) {
    if (caseData.courtName == null &&
        caseData.judgeName == null &&
        caseData.courtCategory == null) {
      return const SizedBox.shrink();
    }

    return _DetailSection(
      title: 'Court Information',
      icon: Icons.account_balance_outlined,
      children: [
        if (caseData.courtCategory != null)
          _InfoRow(
              Icons.balance_outlined, 'Category', caseData.courtCategory!.name),
        if (caseData.courtName != null)
          _InfoRow(
              Icons.account_balance_outlined, 'Court', caseData.courtName!),
        if (caseData.judgeName != null)
          _InfoRow(Icons.gavel_outlined, 'Judge', caseData.judgeName!),
      ],
    );
  }
}

// ── Notes card (expandable) ───────────────────────────────────────
class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.card],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          leading:
              Icon(Icons.sticky_note_2_outlined, size: 18.sp, color: RC.navy),
          title: Text('Case Notes',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: RC.textPrimary)),
          children: [
            Divider(
                color: RC.divider,
                height: 1,
                thickness: 0.5,
                indent: 14.w,
                endIndent: 14.w),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Text(
                notes,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: RC.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────
class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _DetailSection(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(children: [
              Icon(icon, size: 16.sp, color: RC.navy),
              SizedBox(width: 8.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: RC.navy)),
            ]),
          ),
          Divider(color: RC.divider, height: 1, thickness: 0.5),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: RC.textSecondary),
          SizedBox(width: 10.w),
          Text('$label:',
              style: TextStyle(fontSize: 12.sp, color: RC.textSecondary)),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: RC.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimestampRow extends StatelessWidget {
  final String label;
  final String value;
  const _TimestampRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, size: 12.sp, color: RC.textTertiary),
          SizedBox(width: 5.w),
          Text('$label: $value',
              style: TextStyle(fontSize: 11.sp, color: RC.textTertiary)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(title,
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary)),
    );
  }
}
