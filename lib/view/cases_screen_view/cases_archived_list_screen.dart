import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/case_resources/archived_case_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_archived_list_view_model.dart';

class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);
  static const divider = Color(0xFFE5E1D8);
}

class CasesArchivedListScreen extends StatefulWidget {
  const CasesArchivedListScreen({super.key});
  @override
  State<CasesArchivedListScreen> createState() =>
      _CasesArchivedListScreenState();
}

class _CasesArchivedListScreenState extends State<CasesArchivedListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseArchivedListViewModel>().fetchArchivedCases();
    });
  }

  bool _nearEnd(ScrollNotification n) =>
      n.metrics.pixels >= n.metrics.maxScrollExtent * 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RC.background,
      appBar: AppBar(
        backgroundColor: _RC.navy,
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
                  style: TextStyle(fontSize: 11.sp, color: _RC.textOnDarkMuted),
                ),
            ],
          ),
        ),
      ),
      body: Consumer<CaseArchivedListViewModel>(
        builder: (_, vm, __) {
          // Initial loading
          if (vm.isFirstLoading) {
            return _SkeletonList();
          }

          // Empty state
          if (vm.archiveCaseList.isEmpty) {
            return _EmptyState();
          }

          // List
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (_nearEnd(n) && !vm.isMoreLoading && vm.hasMore) {
                vm.fetchArchivedCases(loadMore: true);
              }
              return false;
            },
            child: RefreshIndicator(
              color: _RC.navy,
              onRefresh: () async {
                await vm.fetchArchivedCases(loadMore: false, isRefresh: true);
                if (context.mounted) {
                  SnakeBars.flutterToast('Refreshed', context);
                }
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount:
                    vm.archiveCaseList.length + (vm.isMoreLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i < vm.archiveCaseList.length) {
                    return ArchivedCaseCard(caseData: vm.archiveCaseList[i]);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: _RC.navy, strokeWidth: 2),
                    ),
                  );
                },
              ),
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
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _RC.navy.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.archive_outlined,
                  size: 28.sp, color: _RC.navy.withValues(alpha: 0.4)),
            ),
            SizedBox(height: 16.h),
            Text('No archived cases',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.textPrimary)),
            SizedBox(height: 6.h),
            Text(
              'Cases you archive will appear here.\nYou can restore them at any time.',
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
            color: _RC.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
