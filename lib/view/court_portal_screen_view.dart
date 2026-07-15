// lib/screens/court_portal/court_portal_screen.dart
//
// Full Court Portal screen.
// Two tabs: Bench Roster | Certified Copies
// Uses the same _RC design tokens as home_screen.dart and calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/case_models/court_portal_model.dart';
import '../view_model/cases_view_model/case_list_view_model.dart';
import '../view_model/cases_view_model/hearing_create_view_model/court_portal_view_model.dart';

// ─────────────────────────────────────────────
// Design tokens — identical to the rest of the app
// ─────────────────────────────────────────────
class _RC {
  static const navy = Color(0xFF1A2744);
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
  static const dangerText = Color(0xFF991B1B);

  static const successSurface = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);
  static const successText = Color(0xFF166534);

  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);

  static const infoSurface = Color(0xFFEFF6FF);
  static const infoBorder = Color(0xFFBFDBFE);
  static const infoText = Color(0xFF1E40AF);

  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10.r,
        offset: const Offset(0, 3),
      );
}

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
      backgroundColor: _RC.background,
      appBar: _buildAppBar(context),
      floatingActionButton: Consumer<CourtPortalViewModel>(
        builder: (_, vm, __) {
          if (vm.activeTab != CourtPortalTab.copies) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: _RC.navy,
            foregroundColor: _RC.textOnDark,
            icon: const Icon(Icons.add),
            label: const Text('New Application',
                style: TextStyle(fontWeight: FontWeight.w500)),
            onPressed: () => _showAddCopySheet(context, vm),
          );
        },
      ),
      body: Consumer<CourtPortalViewModel>(
        builder: (_, vm, __) => RefreshIndicator(
          color: _RC.navy,
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
      backgroundColor: _RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Virtual Court Room',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textOnDark)),
          Text('Bench roster & certified copies',
              style: TextStyle(fontSize: 11.sp, color: _RC.textOnDarkMuted)),
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
      color: _RC.navy,
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
            color: isActive ? _RC.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14.sp,
                  color: isActive ? _RC.navy : _RC.textOnDarkMuted),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? _RC.navy : _RC.textOnDarkMuted,
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
              color: _RC.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _RC.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$totalCases cases',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _RC.navy,
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
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final bench = widget.bench;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
      ),
      child: Column(
        children: [
          // Header row — tap to expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: _RC.navy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                  bottomLeft: _expanded ? Radius.zero : Radius.circular(14.r),
                  bottomRight: _expanded ? Radius.zero : Radius.circular(14.r),
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
                        size: 17.sp, color: _RC.textOnDark),
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
                            color: _RC.textOnDark,
                          ),
                        ),
                        if (bench.hasJudge)
                          Text(
                            bench.judgeName!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: _RC.textOnDarkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _RC.gold,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${bench.caseCount}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _RC.textOnDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _RC.textOnDarkMuted,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Case rows
          if (_expanded)
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
            : Border(bottom: BorderSide(color: _RC.divider, width: 0.5)),
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
                    color: _RC.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Text(
                      item.caseNumber,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: _RC.textSecondary,
                      ),
                    ),
                    if (item.nextHearingAt != null) ...[
                      Text(' · ',
                          style: TextStyle(
                              fontSize: 10.sp, color: _RC.textTertiary)),
                      Icon(Icons.event_outlined, size: 10.sp, color: _RC.gold),
                      SizedBox(width: 3.w),
                      Text(
                        item.formattedNextHearing!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _RC.gold,
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
                color: _RC.infoSurface,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                item.caseStageName!,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: _RC.infoText,
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
                  color: isActive ? _RC.navy : _RC.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isActive ? _RC.navy : _RC.divider,
                    width: isActive ? 0 : 0.5,
                  ),
                  boxShadow: isActive ? [_RC.card] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isActive ? _RC.textOnDark : _RC.textSecondary,
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
                            color: isActive
                                ? _RC.textOnDark
                                : _statusColor(filter),
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
        return _RC.infoText;
      case CopyFilter.processing:
        return _RC.warningText;
      case CopyFilter.ready:
        return _RC.successText;
      default:
        return _RC.textSecondary;
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
        color: _RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [_RC.card],
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
                          color: _RC.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.tag,
                              size: 10.sp, color: _RC.textSecondary),
                          SizedBox(width: 3.w),
                          Text(
                            copy.referenceNumber,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: _RC.textSecondary,
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
                  color: _RC.textSecondary,
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
                color: isDone ? _RC.navy : _RC.divider,
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
        ? _RC.navy
        : isCurrent
            ? _RC.navy.withValues(alpha: 0.1)
            : _RC.divider;
    final Color fg = isDone
        ? _RC.textOnDark
        : isCurrent
            ? _RC.navy
            : _RC.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: _RC.navy, width: 1.5) : null,
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
            color: isCurrent ? _RC.navy : _RC.textTertiary,
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
        bg = _RC.infoSurface;
        fg = _RC.infoText;
        break;
      case CopyStatus.processing:
        bg = _RC.warningSurface;
        fg = _RC.warningText;
        break;
      case CopyStatus.ready:
        bg = _RC.successSurface;
        fg = _RC.successText;
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
                backgroundColor: _RC.navy.withValues(alpha: 0.06),
                foregroundColor: _RC.navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              icon: isAdvancing
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: _RC.navy),
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
                size: 18.sp, color: _RC.danger),
            onPressed: () => _confirmDelete(context),
            style: IconButton.styleFrom(
              backgroundColor: _RC.dangerSurface,
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
                color: _RC.successSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _RC.successBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 14.sp, color: _RC.successText),
                  SizedBox(width: 6.w),
                  Text(
                    'Ready for collection',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _RC.successText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: const Text('Delete application?'),
        content: const Text(
            'This will permanently remove the certified copy application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _RC.danger),
            onPressed: () {
              Navigator.pop(context);
              vm.deleteCopy(copy.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
  String? _selectedCaseId;
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
          color: _RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
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
                    color: _RC.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'New copy application',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                dropdownColor: _RC.surface,
                initialValue: _selectedCaseId,
                items: casesVM.filterCases
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text("${c.caseNumber} — ${c.firstPartyName}"),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCaseId = value),
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
                    backgroundColor: _RC.navy,
                    foregroundColor: _RC.textOnDark,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: vm.isCreating ? null : () => _submit(context, vm),
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
                    style: TextStyle(fontSize: 12.sp, color: _RC.danger)),
            ],
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
    if (_selectedCaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a case first')),
      );
      return;
    }

    final success = await vm.createCopy(
      caseId: _selectedCaseId!,
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
      prefixIcon: Icon(icon, size: 18.sp, color: _RC.textSecondary),
      filled: true,
      fillColor: _RC.background,
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
      hintStyle: TextStyle(color: _RC.textTertiary, fontSize: 12.sp),
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
        color: _RC.textSecondary,
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
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                  color: _RC.navy.withValues(alpha: 0.07),
                  shape: BoxShape.circle),
              child: Icon(Icons.balance_outlined,
                  size: 30.sp, color: _RC.navy.withValues(alpha: 0.4)),
            ),
            SizedBox(height: 16.h),
            Text('No active courts',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.textPrimary)),
            SizedBox(height: 6.h),
            Text(
              'Cases with a court name assigned will appear here grouped by court and judge.',
              style: TextStyle(
                  fontSize: 12.sp, color: _RC.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
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
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                  color: _RC.navy.withValues(alpha: 0.07),
                  shape: BoxShape.circle),
              child: Icon(Icons.file_copy_outlined,
                  size: 28.sp, color: _RC.navy.withValues(alpha: 0.4)),
            ),
            SizedBox(height: 16.h),
            Text(
              isFiltered
                  ? 'No ${filter.label.toLowerCase()} copies'
                  : 'No applications yet',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textPrimary),
            ),
            SizedBox(height: 6.h),
            Text(
              isFiltered
                  ? 'No copies are currently in "${filter.label}" status.'
                  : 'Tap the button below to apply for a certified copy.',
              style: TextStyle(
                  fontSize: 12.sp, color: _RC.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
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
            color: _RC.divider.withValues(alpha: 0.5),
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
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: TextStyle(fontSize: 13.sp, color: _RC.dangerText),
                textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _RC.navy),
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
