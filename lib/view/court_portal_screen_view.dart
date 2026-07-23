// lib/screens/court_portal/court_portal_screen.dart
//
// Full Court Portal screen.
// Two tabs: Bench Roster | Certified Copies
// Uses the same _RC design tokens as home_screen.dart and calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/resources/system_design/rc_widgets.dart';

import '../models/case_models/court_portal_model.dart';
import '../view_model/cases_view_model/case_list_view_model.dart';
import '../view_model/cases_view_model/hearing_create_view_model/court_portal_view_model.dart';

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class CourtPortalScreen extends StatefulWidget {
  const CourtPortalScreen({super.key});

  @override
  State<CourtPortalScreen> createState() => _CourtPortalScreenState();
}

class _CourtPortalScreenState extends State<CourtPortalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtPortalViewModel>().initialLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.background,
      appBar: _buildAppBar(context),
      floatingActionButton: Consumer<CourtPortalViewModel>(
        builder: (_, vm, __) {
          if (vm.activeTab != CourtPortalTab.copies) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: RC.navy,
            foregroundColor: RC.textOnDark,
            icon: const Icon(Icons.add),
            label: const Text('New Application',
                style: TextStyle(fontWeight: FontWeight.w500)),
            onPressed: () => _showAddCopySheet(context, vm),
          );
        },
      ),
      body: Consumer<CourtPortalViewModel>(
        builder: (_, vm, __) => RefreshIndicator(
          color: RC.navy,
          onRefresh: vm.refresh,
          child: Column(
            children: [
              _TabBar(vm: vm),
              Expanded(
                child: vm.activeTab == CourtPortalTab.roster
                    ? _RosterTab(vm: vm)
                    : _CopiesTab(vm: vm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Virtual Court Room',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: RC.textOnDark)),
          Text('Bench roster & certified copies',
              style: TextStyle(fontSize: 11.sp, color: RC.textOnDarkMuted)),
        ],
      ),
    );
  }

  void _showAddCopySheet(BuildContext context, CourtPortalViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _AddCopySheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab bar — Roster | Copies
// ─────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final CourtPortalViewModel vm;
  const _TabBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RC.navy,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Bench Roster',
              icon: Icons.balance_outlined,
              isActive: vm.activeTab == CourtPortalTab.roster,
              onTap: () => vm.switchTab(CourtPortalTab.roster),
            ),
            _TabButton(
              label: 'Certified Copies',
              icon: Icons.file_copy_outlined,
              isActive: vm.activeTab == CourtPortalTab.copies,
              onTap: () => vm.switchTab(CourtPortalTab.copies),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isActive ? RC.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14.sp, color: isActive ? RC.navy : RC.textOnDarkMuted),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? RC.navy : RC.textOnDarkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TAB 1: BENCH ROSTER
// ══════════════════════════════════════════════
class _RosterTab extends StatelessWidget {
  final CourtPortalViewModel vm;
  const _RosterTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isRosterLoading) return const _Skeleton();
    if (vm.rosterError != null) {
      return _ErrorState(message: vm.rosterError!, onRetry: vm.loadRoster);
    }
    if (vm.roster == null || vm.roster!.benches.isEmpty) {
      return _RosterEmptyState();
    }

    final roster = vm.roster!;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 100.h),
      itemCount: roster.benches.length + 1, // +1 for header
      itemBuilder: (_, i) {
        if (i == 0) {
          return _RosterHeader(totalCases: roster.totalCases);
        }
        return _BenchCard(bench: roster.benches[i - 1]);
      },
    );
  }
}

class _RosterHeader extends StatelessWidget {
  final int totalCases;
  const _RosterHeader({required this.totalCases});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Text(
            'Active courts',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: RC.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: RC.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$totalCases cases',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: RC.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenchCard extends StatefulWidget {
  final BenchCardModel bench;
  const _BenchCard({required this.bench});

  @override
  State<_BenchCard> createState() => _BenchCardState();
}

class _BenchCardState extends State<_BenchCard> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourtPortalViewModel>();
    final bench = widget.bench;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        children: [
          // Header row — tap to expand/collapse
          InkWell(
            onTap: () => vm.toggleExpand(),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: RC.navy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                  bottomLeft:
                      vm.isExpanded ? Radius.zero : Radius.circular(14.r),
                  bottomRight:
                      vm.isExpanded ? Radius.zero : Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.balance_outlined,
                        size: 17.sp, color: RC.textOnDark),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bench.courtName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: RC.textOnDark,
                          ),
                        ),
                        if (bench.hasJudge)
                          Text(
                            bench.judgeName!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: RC.textOnDarkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: RC.gold,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${bench.caseCount}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: RC.textOnDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    vm.isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: RC.textOnDarkMuted,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Case rows
          if (vm.isExpanded)
            ...bench.cases.asMap().entries.map(
                  (entry) => _RosterCaseRow(
                    item: entry.value,
                    isLast: entry.key == bench.cases.length - 1,
                  ),
                ),
        ],
      ),
    );
  }
}

class _RosterCaseRow extends StatelessWidget {
  final RosterCaseItem item;
  final bool isLast;
  const _RosterCaseRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: RC.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.caseTitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: RC.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Text(
                      item.caseNumber,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: RC.textSecondary,
                      ),
                    ),
                    if (item.nextHearingAt != null) ...[
                      Text(' · ',
                          style: TextStyle(
                              fontSize: 10.sp, color: RC.textTertiary)),
                      Icon(Icons.event_outlined, size: 10.sp, color: RC.gold),
                      SizedBox(width: 3.w),
                      Text(
                        item.formattedNextHearing!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: RC.gold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (item.caseStageName != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: RC.infoSurface,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                item.caseStageName!,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: RC.infoText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TAB 2: CERTIFIED COPIES
// ══════════════════════════════════════════════
class _CopiesTab extends StatelessWidget {
  final CourtPortalViewModel vm;
  const _CopiesTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isCopiesLoading) return const _Skeleton();
    if (vm.copiesError != null) {
      return _ErrorState(message: vm.copiesError!, onRetry: vm.loadCopies);
    }

    return Column(
      children: [
        _CopyFilterRow(vm: vm),
        Expanded(
          child: vm.filteredCopies.isEmpty
              ? _CopiesEmptyState(filter: vm.activeFilter)
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 100.h),
                  itemCount: vm.filteredCopies.length,
                  itemBuilder: (_, i) => _CopyCard(
                    copy: vm.filteredCopies[i],
                    vm: vm,
                  ),
                ),
        ),
      ],
    );
  }
}

class _CopyFilterRow extends StatelessWidget {
  final CourtPortalViewModel vm;
  const _CopyFilterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: CopyFilter.values.map((filter) {
          final count = vm.countByStatus(filter);
          final isActive = vm.activeFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
            child: GestureDetector(
              onTap: () => vm.setFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? RC.navy : RC.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive ? RC.navy : RC.divider,
                    width: isActive ? 0 : 0.5,
                  ),
                  boxShadow: isActive ? [RC.cardShadow] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isActive ? RC.textOnDark : RC.textSecondary,
                      ),
                    ),
                    if (count > 0 && filter != CopyFilter.all) ...[
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.25)
                              : _statusColor(filter).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive ? RC.textOnDark : _statusColor(filter),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _statusColor(CopyFilter filter) {
    switch (filter) {
      case CopyFilter.applied:
        return RC.infoText;
      case CopyFilter.processing:
        return RC.warningText;
      case CopyFilter.ready:
        return RC.successText;
      default:
        return RC.textSecondary;
    }
  }
}

class _CopyCard extends StatelessWidget {
  final CertifiedCopyModel copy;
  final CourtPortalViewModel vm;
  const _CopyCard({required this.copy, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [RC.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.caseTitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: RC.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.tag, size: 10.sp, color: RC.textSecondary),
                          SizedBox(width: 3.w),
                          Text(
                            copy.referenceNumber,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: RC.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: copy.status),
              ],
            ),
          ),

          // 3-step tracker
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _CopyTracker(copy: copy),
          ),

          if (copy.description != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Text(
                copy.description!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: RC.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Action row
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 8.h),
            child: _CopyActions(copy: copy, vm: vm),
          ),
        ],
      ),
    );
  }
}

// ── 3-step progress tracker ──────────────────────────────────
class _CopyTracker extends StatelessWidget {
  final CertifiedCopyModel copy;
  const _CopyTracker({required this.copy});

  @override
  Widget build(BuildContext context) {
    final steps = [CopyStatus.applied, CopyStatus.processing, CopyStatus.ready];
    final currentIndex = steps.indexOf(copy.status);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isDone = currentIndex > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? RC.navy : RC.divider,
              ),
            );
          }
          // Step circle
          final stepIndex = i ~/ 2;
          final step = steps[stepIndex];
          final isDone = currentIndex > stepIndex;
          final isCurrent = currentIndex == stepIndex;

          return _StepCircle(
            step: step,
            isDone: isDone,
            isCurrent: isCurrent,
          );
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final CopyStatus step;
  final bool isDone;
  final bool isCurrent;
  const _StepCircle(
      {required this.step, required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? RC.navy
        : isCurrent
            ? RC.navy.withValues(alpha: 0.1)
            : RC.divider;
    final Color fg = isDone
        ? RC.textOnDark
        : isCurrent
            ? RC.navy
            : RC.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: RC.navy, width: 1.5) : null,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : _stepIcon(step),
            size: 14.sp,
            color: fg,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          step.label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: isCurrent ? RC.navy : RC.textTertiary,
          ),
        ),
      ],
    );
  }

  IconData _stepIcon(CopyStatus s) {
    switch (s) {
      case CopyStatus.applied:
        return Icons.send_outlined;
      case CopyStatus.processing:
        return Icons.autorenew_outlined;
      case CopyStatus.ready:
        return Icons.task_alt_outlined;
    }
  }
}

// ── Status badge ──────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final CopyStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case CopyStatus.applied:
        bg = RC.infoSurface;
        fg = RC.infoText;
        break;
      case CopyStatus.processing:
        bg = RC.warningSurface;
        fg = RC.warningText;
        break;
      case CopyStatus.ready:
        bg = RC.successSurface;
        fg = RC.successText;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Copy action buttons ───────────────────────────────────────
class _CopyActions extends StatelessWidget {
  final CertifiedCopyModel copy;
  final CourtPortalViewModel vm;

  const _CopyActions({required this.copy, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isAdvancing = vm.isAdvancing(copy.id);

    return Row(
      children: [
        // Advance button — only shown if not terminal
        if (copy.canAdvance) ...[
          Expanded(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: RC.navy.withValues(alpha: 0.06),
                foregroundColor: RC.navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              icon: isAdvancing
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: RC.navy),
                    )
                  : Icon(Icons.arrow_forward_rounded, size: 15.sp),
              label: Text(
                isAdvancing ? 'Updating...' : 'Mark ${copy.status.next!.label}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              onPressed: isAdvancing ? null : () => vm.advanceStatus(copy),
            ),
          ),
          SizedBox(width: 8.w),
        ],

        // Delete button — only for 'applied' status
        if (copy.canDelete)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                size: 18.sp, color: RC.danger),
            onPressed: () => _confirmDelete(
              context,
              () => vm.deleteCopy(copy.id),
            ),
            style: IconButton.styleFrom(
              backgroundColor: RC.dangerSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
          ),

        // Ready state — collection hint
        if (copy.isComplete)
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: RC.successSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: RC.successBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 14.sp, color: RC.successText),
                  SizedBox(width: 6.w),
                  Text(
                    'Ready for collection',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: RC.successText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback? onDelete) {
    RCConfirmDialog.show(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: RC.danger,
      iconSurface: RC.dangerSurface,
      title: 'Delete application?',
      message: 'This will permanently remove the certified copy application.',
      confirmLabel: 'Delete',
      confirmColor: RC.danger,
      confirmSurface: RC.dangerSurface,
      confirmBorder: RC.dangerBorder,
      onConfirm: () async => onDelete?.call(),
    );
  }
}

// ══════════════════════════════════════════════
// ADD COPY BOTTOM SHEET
// ══════════════════════════════════════════════
class _AddCopySheet extends StatefulWidget {
  const _AddCopySheet();

  @override
  State<_AddCopySheet> createState() => _AddCopySheetState();
}

class _AddCopySheetState extends State<_AddCopySheet> {
  final _refController = TextEditingController();
  final _descController = TextEditingController();
  final _caseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _refController.dispose();
    _descController.dispose();
    _caseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourtPortalViewModel>();
    final casesVM = context.read<CaseListViewModel>();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: RC.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  'New copy application',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  dropdownColor: RC.surface,
                  initialValue: vm.selectedCaseId,
                  items: casesVM.filterCases
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child:
                                Text("${c.caseNumber} — ${c.firstPartyName}"),
                          ))
                      .toList(),
                  onChanged: (value) => vm.getSelectedCaseId(value),
                  validator: (v) => v == null ? "Please select a case" : null,
                  decoration: _inputDecoration(
                    "Select a case",
                    Icons.cases_outlined,
                  ),
                ),
                SizedBox(height: 16.h),
                // Reference number field
                _FieldLabel('Reference number *'),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _refController,
                  decoration: _inputDecoration('e.g. CC-2026-0412', Icons.tag),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Reference number is required'
                      : null,
                  textCapitalization: TextCapitalization.characters,
                ),
                SizedBox(height: 12.h),

                // Description field
                _FieldLabel('Description (optional)'),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _descController,
                  decoration: _inputDecoration(
                      'e.g. Order sheet dated 15 June 2026',
                      Icons.description_outlined),
                  maxLines: 2,
                ),
                SizedBox(height: 20.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RC.navy,
                      foregroundColor: RC.textOnDark,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed:
                        vm.isCreating ? null : () => _submit(context, vm),
                    child: vm.isCreating
                        ? SizedBox(
                            height: 18.h,
                            width: 18.w,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Submit application',
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: 8.h),

                if (vm.createError != null)
                  Text(vm.createError!,
                      style: TextStyle(fontSize: 12.sp, color: RC.danger)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, CourtPortalViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    // NOTE: In a real implementation, add a case selector dropdown here
    // using your existing cases list from CasesViewModel.
    // For now, this requires a valid caseId to be passed.
    // See INTEGRATION.dart Step 5 for the case selector pattern.
    if (vm.selectedCaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a case first')),
      );
      return;
    }

    final success = await vm.createCopy(
      caseId: vm.selectedCaseId!,
      referenceNumber: _refController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18.sp, color: RC.textSecondary),
      filled: true,
      fillColor: RC.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: RC.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: RC.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: RC.navy, width: 1.5),
      ),
      hintStyle: TextStyle(color: RC.textTertiary, fontSize: 12.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

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

// ══════════════════════════════════════════════
// EMPTY STATES
// ══════════════════════════════════════════════
class _RosterEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: RC.navy.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.balance_outlined,
                size: 32.sp,
                color: RC.navy.withValues(alpha: 0.4),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text('No active courts', style: RC.heading())
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              'Cases with a court name assigned will appear here grouped by court and judge.',
              style: RC.body(color: RC.textSecondary),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _CopiesEmptyState extends StatelessWidget {
  final CopyFilter filter;
  const _CopiesEmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != CopyFilter.all;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                  color: RC.navy.withValues(alpha: 0.07),
                  shape: BoxShape.circle),
              child: Icon(
                Icons.file_copy_outlined,
                size: 32.sp,
                color: RC.navy.withValues(alpha: 0.4),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text(
              isFiltered
                  ? 'No ${filter.label.toLowerCase()} copies'
                  : 'No applications yet',
              style: RC.heading(),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              isFiltered
                  ? 'No copies are currently in "${filter.label}" status.'
                  : 'Tap the button below to apply for a certified copy.',
              style: RC.body(color: RC.textSecondary),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: List.generate(
        3,
        (_) => Container(
          height: 100.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: RC.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? title;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // No borders, no shadows. It sits natively on whatever background it's placed over.
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Polite, Muted Icon
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: RC.danger.withValues(alpha: 0.08), // Soft tint
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .cloud_off_rounded, // A softer conceptual icon than an alert triangle
                color: RC.danger.withValues(alpha: 0.9),
                size: 32.sp,
              ),
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),

            SizedBox(height: 16.h),

            // 2. Integrated Typography (Using Standard UI Colors)
            Text(
              title ?? 'Couldn\'t load data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: RC
                    .textPrimary, // Blends perfectly with your standard app headers
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 6.h),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:
                    RC.textSecondary, // Blends with your standard app subtitles
                height: 1.4,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 16.h),

            // 3. Tonal, Inline Action Button
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: RC.navy, // Your standard primary action color
                backgroundColor: RC.navy
                    .withValues(alpha: 0.06), // Very soft "Tonal" background
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
