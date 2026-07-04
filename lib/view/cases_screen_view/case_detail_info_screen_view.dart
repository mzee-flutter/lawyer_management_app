import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/case_resources/case_file_section_view.dart';
import 'package:right_case/resources/client_resources/related_client_info_card.dart';
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
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:uuid/uuid.dart';

class _RC {
  static const navy = Color(0xFF1A2744);
  static const navyLight = Color(0xFF243356);
  static const gold = Color(0xFFC8952A);
  static const goldLight = Color(0xFFFAEDD4);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);
  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const successText = Color(0xFF166534);
  static const successSurface = Color(0xFFF0FDF4);
  static const infoText = Color(0xFF1E40AF);
  static const infoSurface = Color(0xFFEFF6FF);
  static const warningText = Color(0xFF92400E);
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  static Color statusColor(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'running':
        return infoText;
      case 'decided':
        return successText;
      case 'abandoned':
      case 'cancelled':
        return danger;
      case 'pending':
      case 'date awaited':
        return warningText;
      default:
        return navy;
    }
  }

  static Color statusSurface(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'running':
        return infoSurface;
      case 'decided':
        return successSurface;
      case 'abandoned':
      case 'cancelled':
        return dangerSurface;
      case 'pending':
      case 'date awaited':
        return warningSurface;
      default:
        return navy.withValues(alpha: 0.08);
    }
  }
}

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseFilesViewModel>().loadFilesFromCase(context);
      final rcVM = context.read<RelatedClientViewModel>();
      rcVM.loadRelatedClientsFromCase(context);
      rcVM.syncUnSyncedClients(context);
    });
  }

  void _openUploadSheet() {
    if (_isUploadSheetOpen) return;
    _isUploadSheetOpen = true;
    _showUploadSheet(
      context: context,
      caseId: widget.caseId,
      filesVM: context.read<CaseFilesViewModel>(),
    );
  }

  void _closeUploadSheet() {
    if (!_isUploadSheetOpen) return;
    _isUploadSheetOpen = false;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final caseData =
        context.watch<CaseListViewModel>().getCaseById(widget.caseId);

    if (caseData == null) {
      return Scaffold(
        backgroundColor: _RC.background,
        appBar: AppBar(
          backgroundColor: _RC.navy,
          iconTheme: const IconThemeData(color: Colors.white),
          title:
              const Text('Case Details', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Case not found.')),
      );
    }

    return Consumer<AddCaseFileViewModel>(
      builder: (context, addFileVM, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (addFileVM.status == UploadStatus.readyToUpload) {
            _openUploadSheet();
          }
          if (addFileVM.status == UploadStatus.idle && _isUploadSheetOpen) {
            _closeUploadSheet();
          }
          if (addFileVM.status == UploadStatus.success) {
            _closeUploadSheet();
            SnakeBars.flutterToast('Files uploaded successfully', context);
            addFileVM.cancelUploadWorkflow();
          }
          if (addFileVM.status == UploadStatus.error) {
            _closeUploadSheet();
            SnakeBars.flutterToast(addFileVM.error ?? 'Upload failed', context);
            addFileVM.cancelUploadWorkflow();
          }
        });

        return Scaffold(
          backgroundColor: _RC.background,
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
                  onAddFiles: () => addFileVM.pickFiles(),
                  onAddClient: () => _showAddClientsSheet(
                      context: context, caseId: caseData.id),
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
                    value:
                        DateFormat('dd MMM yyyy').format(caseData.createdAt)),
                if (caseData.updatedAt != null)
                  _TimestampRow(
                      label: 'Updated',
                      value: DateFormat('dd MMM yyyy')
                          .format(caseData.updatedAt!)),
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
                              color: _RC.background,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: rcVM.isSyncing
                                ? SizedBox(
                                    height: 16.h,
                                    width: 16.w,
                                    child: CircularProgressIndicator(
                                        color: _RC.navy, strokeWidth: 2))
                                : Icon(Icons.refresh,
                                    size: 18.sp, color: _RC.navy),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Consumer<RelatedClientViewModel>(
                  builder: (_, rcVM, __) => _RelatedClientsList(
                    relatedClients: rcVM.relatedClients,
                  ),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CaseModel caseData) {
    return AppBar(
      backgroundColor: _RC.navy,
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
            icon: Icon(Icons.edit_outlined, size: 16.sp, color: _RC.gold),
            label: Text('Edit',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: _RC.gold,
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
        color: _RC.navy,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [_RC.card],
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
                  color: _RC.textOnDarkMuted),
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
            style: TextStyle(fontSize: 13.sp, color: _RC.textOnDarkMuted),
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
                color: _RC.textOnDarkMuted),
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
                    color: _RC.statusSurface(statusName),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _RC.statusColor(statusName)),
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
                        color: _RC.textOnDarkMuted),
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
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: Icons.event_available_outlined,
            label: 'Hearings',
            color: _RC.navy,
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
            color: _RC.gold,
            onTap: onAddClient,
          ),
          _Divider(),
          _ActionBtn(
            icon: Icons.upload_file_outlined,
            label: 'Add Files',
            color: _RC.navy,
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
    return Container(height: 36.h, width: 0.5, color: _RC.divider);
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
                    color: _RC.textSecondary)),
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
        caseData.courtCategory == null) return const SizedBox.shrink();

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
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          leading:
              Icon(Icons.sticky_note_2_outlined, size: 18.sp, color: _RC.navy),
          title: Text('Case Notes',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textPrimary)),
          children: [
            Divider(
                color: _RC.divider,
                height: 1,
                thickness: 0.5,
                indent: 14.w,
                endIndent: 14.w),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Text(notes,
                  style: TextStyle(
                      fontSize: 13.sp, color: _RC.textSecondary, height: 1.5)),
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
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(children: [
              Icon(icon, size: 16.sp, color: _RC.navy),
              SizedBox(width: 8.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _RC.navy)),
            ]),
          ),
          Divider(color: _RC.divider, height: 1, thickness: 0.5),
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
          Icon(icon, size: 15.sp, color: _RC.textSecondary),
          SizedBox(width: 10.w),
          Text('$label:',
              style: TextStyle(fontSize: 12.sp, color: _RC.textSecondary)),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: _RC.textPrimary),
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
          Icon(Icons.schedule_outlined, size: 12.sp, color: _RC.textTertiary),
          SizedBox(width: 5.w),
          Text('$label: $value',
              style: TextStyle(fontSize: 11.sp, color: _RC.textTertiary)),
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
              color: _RC.textPrimary)),
    );
  }
}

class _RelatedClientsList extends StatelessWidget {
  final List<RelatedClientModel> relatedClients;
  const _RelatedClientsList({required this.relatedClients});

  @override
  Widget build(BuildContext context) {
    if (relatedClients.isEmpty) {
      return Text('No related clients added.',
          style: TextStyle(fontSize: 13.sp, color: _RC.textTertiary));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: relatedClients.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final rc = relatedClients[i];
        return RelatedClientInfoCard(
          isSynced: rc.isSynced,
          client: rc.client,
          onRemoveFromCase: () async {
            final vm = context.read<RelatedClientViewModel>();
            final ok = await vm.removeRelatedClient(context, rc);
            if (!context.mounted) return;
            SnakeBars.flutterToast(
              ok ? 'Client removed' : 'Failed to remove',
              context,
            );
          },
        );
      },
    );
  }
}

// ── Upload bottom sheet ──────────────────────────────────────────
void _showUploadSheet({
  required BuildContext context,
  required String caseId,
  required CaseFilesViewModel filesVM,
}) {
  final addVM = context.read<AddCaseFileViewModel>();
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: addVM,
      child: _UploadSheet(caseId: caseId, filesVM: filesVM),
    ),
  );
}

class _UploadSheet extends StatelessWidget {
  final String caseId;
  final CaseFilesViewModel filesVM;
  const _UploadSheet({required this.caseId, required this.filesVM});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddCaseFileViewModel>();
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 16.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
      decoration: BoxDecoration(
        color: _RC.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                  color: _RC.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              Icon(Icons.upload_file_outlined, size: 20.sp, color: _RC.navy),
              SizedBox(width: 8.w),
              Text('Uploading Files',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _RC.textPrimary)),
            ],
          ),
          SizedBox(height: 14.h),
          if (vm.selectedFiles.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text('No files selected',
                  style: TextStyle(color: _RC.textTertiary)),
            )
          else
            Column(
              children: vm.selectedFiles.map((f) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: _RC.background,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _RC.divider, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insert_drive_file_outlined,
                              size: 16.sp, color: _RC.navy),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              f.file.path.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.sp, color: _RC.textPrimary),
                            ),
                          ),
                          if (vm.status != UploadStatus.uploading)
                            Icon(Icons.check_circle_outline,
                                size: 16.sp, color: _RC.successText)
                          else
                            Text(
                              '${(f.progress * 100).toInt()}%',
                              style:
                                  TextStyle(fontSize: 11.sp, color: _RC.navy),
                            ),
                        ],
                      ),
                      if (vm.status == UploadStatus.uploading)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: LinearProgressIndicator(
                            value: f.progress,
                            backgroundColor: _RC.divider,
                            valueColor: AlwaysStoppedAnimation(_RC.navy),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    side: BorderSide(color: _RC.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: vm.status == UploadStatus.uploading
                      ? null
                      : () => context
                          .read<AddCaseFileViewModel>()
                          .cancelUploadWorkflow(),
                  child: Text('Cancel',
                      style: TextStyle(color: _RC.textSecondary)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _RC.navy,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                  onPressed: vm.status == UploadStatus.uploading
                      ? null
                      : () async {
                          final uploaded = await vm.uploadFiles(caseId);
                          filesVM.addFile(context, uploaded);
                        },
                  child: vm.status == UploadStatus.uploading
                      ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Upload',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add related clients sheet ────────────────────────────────────
void _showAddClientsSheet(
    {required BuildContext context, required String caseId}) {
  context.read<RelatedClientViewModel>().resetSelectedClients();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: context.read<RelatedClientViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<AddRelatedClientViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<ClientListViewModel>()),
      ],
      child: _AddClientsSheet(caseId: caseId),
    ),
  );
}

class _AddClientsSheet extends StatefulWidget {
  final String caseId;
  const _AddClientsSheet({required this.caseId});
  @override
  State<_AddClientsSheet> createState() => _AddClientsSheetState();
}

class _AddClientsSheetState extends State<_AddClientsSheet> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ClientListViewModel>();
      if (vm.filterClients.isEmpty && !vm.isLoading) {
        vm.fetchClientList();
      }
    });
  }

  void _onScroll() {
    final vm = context.read<ClientListViewModel>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      if (vm.canLoadMore) vm.fetchClientList(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientVM = context.watch<ClientListViewModel>();
    final rcVM = context.watch<RelatedClientViewModel>();
    final addRcVM = context.watch<AddRelatedClientViewModel>();

    final selectable = clientVM.filterClients
        .where((c) => !rcVM.isClientAlreadyAdded(c.id))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: Container(
          decoration: BoxDecoration(
            color: _RC.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 36.w,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _RC.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: 12.h),
              Text('Add Related Clients',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _RC.textPrimary)),
              Divider(color: _RC.divider, height: 1),
              Expanded(
                child: clientVM.isLoading && selectable.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                            color: _RC.navy, strokeWidth: 2))
                    : ListView.builder(
                        controller: _scroll,
                        itemCount: selectable.length +
                            (clientVM.isLoadingMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == selectable.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.r),
                                child: CircularProgressIndicator(
                                    color: _RC.navy, strokeWidth: 2),
                              ),
                            );
                          }
                          final c = selectable[i];
                          return CheckboxListTile(
                            activeColor: _RC.navy,
                            value: rcVM.isClientBoxIsChecked(c.id),
                            title: Text(c.name,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(c.phone.toString(),
                                style: TextStyle(
                                    fontSize: 12.sp, color: _RC.textSecondary)),
                            onChanged: (v) => rcVM.onCheckBoxChange(v, c.id),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _RC.navy,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    onPressed: rcVM.selectedClientsIds.isEmpty ||
                            addRcVM.loading
                        ? null
                        : () async {
                            final selected = clientVM.filterClients
                                .where((c) =>
                                    rcVM.selectedClientsIds.contains(c.id))
                                .map((c) => RelatedClientModel(
                                      id: 'temp_${const Uuid().v4()}',
                                      client: c,
                                      role: 'Evident',
                                      isSynced: false,
                                    ))
                                .toList();

                            rcVM.addRelatedClientsLocally(context, selected);
                            await rcVM.syncUnSyncedClients(context);
                            if (context.mounted) Navigator.pop(context);
                          },
                    child: addRcVM.loading
                        ? SizedBox(
                            height: 18.h,
                            width: 18.h,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Add Selected Clients',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
