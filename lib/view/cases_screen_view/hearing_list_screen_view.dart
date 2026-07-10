import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/case_resources/hearing_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/cases_screen_view/cases_list_screen_view.dart';
import 'package:right_case/view/cases_screen_view/hearing_create_screen_view.dart';
import 'package:right_case/view/cases_screen_view/hearing_update_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_delete_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';

import '../../resources/system_design/rc_theme.dart';
import '../../resources/system_design/rc_widgets.dart';
import '../../view_model/cases_view_model/single_case_view_model.dart';

class HearingListScreenView extends StatefulWidget {
  final String caseId;
  final String? hearingId;

  const HearingListScreenView(
      {super.key, required this.caseId, this.hearingId});

  @override
  State<HearingListScreenView> createState() => _HearingListScreenViewState();
}

class _HearingListScreenViewState extends State<HearingListScreenView> {
  @override
  void initState() {
    super.initState();
    final hearingListVM = context.read<HearingListViewModel>();
    hearingListVM.addListenerToScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      hearingListVM.hearingList.clear();
      hearingListVM.fetchHearingList(widget.caseId);

      final localCase =
          context.read<CaseListViewModel>().getCaseById(widget.caseId);
      if (localCase == null) {
        context.read<SingleCaseViewModel>().fetchSingleCase(widget.caseId);
      }
    });
  }

  Future<void> _onRefresh() async {
    final hearingListVM = context.read<HearingListViewModel>();
    hearingListVM.hearingList.clear();
    await hearingListVM.fetchHearingList(widget.caseId);
  }

  @override
  Widget build(BuildContext context) {
    final singleCaseVM = context.watch<SingleCaseViewModel>();
    final caseListVM = context.watch<CaseListViewModel>();
    final hearingListVM = context.watch<HearingListViewModel>();
    final hearingDeleteVM = context.read<HearingDeleteViewModel>();

    var caseData = caseListVM.getCaseById(widget.caseId);
    caseData ??= singleCaseVM.singleCaseData;

    final isSingleCaseLoading = caseData == null &&
        (singleCaseVM.isLoading || singleCaseVM.singleCaseData == null);
    final isHearingListLoading =
        hearingListVM.isLoading && hearingListVM.hearingList.isEmpty;
    final showSkeleton = isSingleCaseLoading || isHearingListLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop(result);
        } else {
          navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const CasesListScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: RC.background,
        appBar: _HearingsAppBar(count: hearingListVM.hearingList.length),
        body: showSkeleton
            ? const _HearingListSkeleton()
            : hearingListVM.hearingList.isEmpty
                ? const RCEmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No Hearings Yet',
                    message:
                        'Scheduled hearings for this case will appear here.',
                  )
                : RefreshIndicator(
                    color: RC.gold,
                    backgroundColor: RC.surface,
                    strokeWidth: 2,
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: hearingListVM.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      itemCount: hearingListVM.hearingList.length,
                      itemBuilder: (context, index) {
                        final hearing = hearingListVM.hearingList[index];
                        final isHighlighted = hearing.id == widget.hearingId;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: HearingInfoCard(
                            judgeName: caseData?.judgeName ?? 'N/A',
                            courtName: caseData?.courtName ?? 'N/A',
                            isHighLighted: isHighlighted,
                            hearing: hearing,
                            onManage: () {},
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HearingUpdateScreenView(
                                      hearingData: hearing)),
                            ),
                            onDeleteHearing: hearingDeleteVM.isLoading
                                ? null
                                : () async {
                                    try {
                                      await hearingDeleteVM.deleteHearing(
                                          context, hearing.id);
                                      hearingListVM
                                          .deleteHearingFromLocal(hearing.id);
                                      if (context.mounted) {
                                        SnakeBars.flutterToast(
                                          'Hearing removed successfully',
                                          context,
                                        );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        SnakeBars.flutterToast(
                                          'Failed to remove hearing',
                                          context,
                                        );
                                      }
                                    }
                                  },
                          ),
                        );
                      },
                    ),
                  ),
        floatingActionButton: Selector<HearingListViewModel, bool>(
          selector: (_, vm) => vm.isButtonIsVisible,
          builder: (context, isVisible, _) {
            return AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 280),
                child: FloatingActionButton.extended(
                  backgroundColor: RC.navy,
                  elevation: 4,
                  icon: const Icon(Icons.edit_calendar_outlined,
                      color: RC.textOnDark),
                  label: Text('Add Hearing',
                      style: TextStyle(
                          color: RC.textOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HearingCreateScreenView(caseId: widget.caseId)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HearingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  const _HearingsAppBar({required this.count});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Case Hearings',
              style: TextStyle(
                  color: RC.textOnDark,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700)),
          Text('$count scheduled',
              style: TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child:
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }
}

class _HearingListSkeleton extends StatelessWidget {
  const _HearingListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: RC.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 140.w,
                height: 14.h,
                decoration: BoxDecoration(
                    color: RC.background,
                    borderRadius: BorderRadius.circular(4.r))),
            SizedBox(height: 10.h),
            Container(
                width: double.infinity,
                height: 11.h,
                decoration: BoxDecoration(
                    color: RC.background,
                    borderRadius: BorderRadius.circular(4.r))),
          ],
        ),
      ),
    );
  }
}
