import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/home_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_archive_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_permanent_delete_view_model.dart';

import '../../resources/case_resources/case_info_card.dart';
import 'case_detail_info_screen_view.dart';
import 'case_update_screen_view.dart';

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
  static const warningText = Color(0xFF92400E);
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );
}

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});
  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseListViewModel>().fetchCaseList();
    });
    _scrollController.addListener(() {
      final vm = context.read<CaseListViewModel>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.85 &&
          !vm.isLoadingMore &&
          vm.hasMore &&
          !vm.isLoading) {
        vm.fetchCaseList(loadMore: true);
      }
      vm.handleScroll(_scrollController.position.userScrollDirection);
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (nav.canPop()) {
          nav.pop();
        } else {
          nav.pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: _RC.background,
        appBar: _buildAppBar(context),
        body: Consumer<CaseListViewModel>(
          builder: (_, vm, __) {
            if (vm.isLoading && vm.filterCases.isEmpty) {
              return _SkeletonList();
            }

            final displayed = vm.filterCases;

            if (displayed.isEmpty) {
              return _EmptyState(
                isSearching: _searchController.text.isNotEmpty,
              );
            }

            return RefreshIndicator(
              color: _RC.navy,
              onRefresh: () async {
                await vm.fetchCaseList(loadMore: false, isRefresh: true);
                if (context.mounted) {
                  SnakeBars.flutterToast('Cases refreshed', context);
                }
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
                itemCount: displayed.length + (vm.hasMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i < 4) {
                    final c = displayed[i];

                    return CaseInfoCard(
                      caseData: c,
                      onDelete: () => _showDeleteSheet(context, c),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaseUpdateScreenView(caseData: c),
                        ),
                      ),
                      onView: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CaseDetailInfoScreenWrapper(caseId: c.id),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: vm.isLoadingMore
                          ? CircularProgressIndicator(
                              color: _RC.navy, strokeWidth: 2)
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: Selector<CaseListViewModel, bool>(
          selector: (_, vm) => vm.isButtonIsVisible,
          builder: (_, visible, __) => AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: FloatingActionButton.extended(
                backgroundColor: _RC.navy,
                icon: const Icon(Icons.cases_outlined, color: Colors.white),
                label: const Text('Add Case',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                onPressed: () =>
                    Navigator.pushNamed(context, RoutesName.caseCreateScreen),
              ),
            ),
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
      title: _showSearch
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search cases…',
                hintStyle: TextStyle(
                  color: _RC.textOnDarkMuted,
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
              ),
            )
          : Consumer<CaseListViewModel>(
              builder: (_, vm, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cases',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (vm.filterCases.isNotEmpty)
                    Text(
                      '${vm.filterCases.length} active',
                      style: TextStyle(
                          fontSize: 11.sp, color: _RC.textOnDarkMuted),
                    ),
                ],
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchController.clear();
            });
          },
        ),
      ],
    );
  }

  void _showDeleteSheet(BuildContext context, CaseModel caseData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
              value: context.read<CaseArchiveViewModel>()),
          ChangeNotifierProvider.value(
              value: context.read<CasePermanentDeleteViewModel>()),
          ChangeNotifierProvider.value(
              value: context.read<CaseListViewModel>()),
        ],
        child: _DeleteCaseSheet(caseData: caseData),
      ),
    );
  }
}

// ── Delete bottom sheet ──────────────────────────────────────────
class _DeleteCaseSheet extends StatelessWidget {
  final CaseModel caseData;
  const _DeleteCaseSheet({required this.caseData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _RC.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E1D8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Icon
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: _RC.dangerSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded,
                size: 26.sp, color: _RC.danger),
          ),
          SizedBox(height: 12.h),

          Text(
            'Delete case?',
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: _RC.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            '${caseData.firstPartyName} vs. '
            '${caseData.oppositePartyName ?? '—'}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: _RC.textSecondary),
          ),
          SizedBox(height: 20.h),

          // Archive option
          Consumer<CaseArchiveViewModel>(
            builder: (_, vm, __) => _SheetButton(
              icon: Icons.archive_outlined,
              label: 'Archive',
              subtitle: 'Hide from active list. Can be restored later.',
              color: const Color(0xFF92400E),
              surface: _RC.warningSurface,
              border: _RC.warningBorder,
              onTap: () async {
                await vm.archiveCase(context, caseData.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.read<CaseListViewModel>().unFocusSearch();
                }
              },
            ),
          ),
          SizedBox(height: 10.h),

          // Delete option
          Consumer<CasePermanentDeleteViewModel>(
            builder: (_, vm, __) => _SheetButton(
              icon: Icons.delete_forever_outlined,
              label: 'Delete permanently',
              subtitle: 'This cannot be undone.',
              color: _RC.danger,
              surface: _RC.dangerSurface,
              border: _RC.dangerBorder,
              onTap: () async {
                await vm.deleteCasePermanent(context, caseData.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(height: 10.h),

          // Cancel
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _RC.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: color)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: color.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 13.sp, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isSearching;
  const _EmptyState({required this.isSearching});

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
                color: _RC.goldLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.cases_outlined,
                size: 28.sp,
                color: _RC.gold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isSearching ? 'No cases found' : 'No cases yet',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _RC.textPrimary),
            ),
            SizedBox(height: 6.h),
            Text(
              isSearching
                  ? 'Try a different case number or party name.'
                  : 'Tap the button below to add your first case.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, color: _RC.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading skeleton ─────────────────────────────────────────────
class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      children: List.generate(
        4,
        (_) => Container(
          height: 130.h,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E1D8).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
