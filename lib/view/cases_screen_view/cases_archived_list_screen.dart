import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/case_resources/archived_case_card.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/resources/system_design/rc_widgets.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_archived_list_view_model.dart';

class CasesArchivedListScreen extends StatefulWidget {
  const CasesArchivedListScreen({super.key});
  @override
  State<CasesArchivedListScreen> createState() =>
      _CasesArchivedListScreenState();
}

class _CasesArchivedListScreenState extends State<CasesArchivedListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseArchivedListViewModel>().fetchArchivedCases();
    });

    // Aligned with CasesListScreen's ScrollController pagination pattern
    // instead of the NotificationListener<ScrollNotification> this screen
    // used previously.
    _scrollController.addListener(() {
      final vm = context.read<CaseArchivedListViewModel>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.85 &&
          vm.canLoadMore) {
        vm.fetchArchivedCases(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.background,
      appBar: AppBar(
        backgroundColor: RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Consumer<CaseArchivedListViewModel>(
          builder: (_, vm, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archived Cases',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              if (vm.archiveCaseList.isNotEmpty)
                Text(
                  '${vm.archiveCaseList.length} cases',
                  style: TextStyle(fontSize: 11.sp, color: RC.textOnDarkMuted),
                ),
            ],
          ),
        ),
      ),
      body: Consumer<CaseArchivedListViewModel>(
        builder: (_, vm, __) {
          if (vm.isFirstLoading) {
            return _SkeletonList();
          }

          // Real failure, nothing to show -- separate from _EmptyState.
          if (vm.hasError && vm.archiveCaseList.isEmpty) {
            return RCErrorState(
              message: vm.errorMessage!,
              onRetry: () => vm.fetchArchivedCases(),
              title: "Couldn't load archived cases",
            );
          }

          if (vm.archiveCaseList.isEmpty) {
            return _EmptyState();
          }

          return RefreshIndicator(
            color: RC.navy,
            onRefresh: () async {
              await vm.fetchArchivedCases(loadMore: false, isRefresh: true);
              if (!context.mounted) return;
              SnakeBars.flutterToast(
                vm.hasError
                    ? (vm.errorMessage ?? 'Refresh failed. Please try again.')
                    : 'Refreshed',
                context,
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: vm.archiveCaseList.length +
                  ((vm.isMoreLoading || (vm.hasError && vm.hasMore)) ? 1 : 0),
              itemBuilder: (_, i) {
                if (i < vm.archiveCaseList.length) {
                  return ArchivedCaseCard(caseData: vm.archiveCaseList[i]);
                }
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: vm.isMoreLoading
                        ? CircularProgressIndicator(
                            color: RC.navy, strokeWidth: 2)
                        : vm.hasError
                            ? TextButton.icon(
                                onPressed: () =>
                                    vm.fetchArchivedCases(loadMore: true),
                                icon: Icon(Icons.refresh_rounded,
                                    size: 16.sp, color: RC.navy),
                                label: Text(
                                  "Couldn't load more · Tap to retry",
                                  style: TextStyle(
                                      color: RC.navy,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
              child: Icon(Icons.archive_outlined,
                  size: 32.sp, color: RC.navy.withValues(alpha: 0.4)),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text(
              'No archived cases',
              style: RC.heading(),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              'Cases you archive will appear here.\nYou can restore them at any time.',
              textAlign: TextAlign.center,
              style: RC.body(color: RC.textSecondary),
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

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      children: List.generate(
        3,
        (_) => Container(
          height: 160.h,
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
