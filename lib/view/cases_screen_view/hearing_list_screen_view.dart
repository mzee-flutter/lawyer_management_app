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

import '../../view_model/cases_view_model/single_case_view_model.dart';

class HearingListScreenView extends StatefulWidget {
  final String caseId;
  final String? hearingId;

  const HearingListScreenView({
    super.key,
    required this.caseId,
    this.hearingId,
  });

  @override
  State<HearingListScreenView> createState() => HearingListScreenViewState();
}

class HearingListScreenViewState extends State<HearingListScreenView> {
  @override
  void initState() {
    super.initState();
    final hearingListVM = context.read<HearingListViewModel>();
    final singleCaseVM = context.read<SingleCaseViewModel>();
    hearingListVM.addListenerToScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      hearingListVM.hearingList.clear();
      hearingListVM.fetchHearingList(widget.caseId);

      final localCase =
          context.read<CaseListViewModel>().getCaseById(widget.caseId);

      if (localCase == null) {
        singleCaseVM.fetchSingleCase(widget.caseId);
      }
    });
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

    final showGlobalSkeleton = isSingleCaseLoading || isHearingListLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop(result);
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const CasesListScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          title: Text(
            "Case Hearings",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        body: showGlobalSkeleton
            ? _buildHearingListShimmerSkeleton()
            : hearingListVM.hearingList.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        "No hearings found.",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: hearingListVM.scrollController,
                    itemCount: hearingListVM.hearingList.length,
                    itemBuilder: (context, index) {
                      final hearing = hearingListVM.hearingList[index];
                      final isHighLighted = hearing.id == widget.hearingId;
                      return HearingInfoCard(
                        judgeName: caseData?.judgeName ?? "N/A",
                        courtName: caseData?.courtName ?? "N/A",
                        isHighLighted: isHighLighted,
                        hearing: hearing,
                        onManage: () {},
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HearingUpdateScreenView(
                                hearingData: hearing,
                              ),
                            ),
                          );
                        },
                        onDeleteHearing: hearingDeleteVM.isLoading
                            ? null
                            : () async {
                                try {
                                  await hearingDeleteVM.deleteHearing(
                                    context,
                                    hearing.id,
                                  );

                                  hearingListVM
                                      .deleteHearingFromLocal(hearing.id);
                                  SnakeBars.flutterToast(
                                    "Hearing removed successfully",
                                    context,
                                  );
                                } catch (e) {
                                  SnakeBars.flutterToast(
                                      "Failed to remove", context);
                                }
                              },
                      );
                    },
                  ),
        floatingActionButton: Selector<HearingListViewModel, bool>(
          selector: (_, vm) => vm.isButtonIsVisible,
          builder: (context, isVisible, child) {
            return AnimatedSlide(
              offset: isVisible ? Offset.zero : Offset(0, 2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0, // Smoothly fades out
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey.shade800,
                  icon: const Icon(Icons.edit_calendar, color: Colors.white),
                  label: const Text(
                    'Add Hearing',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HearingCreateScreenView(caseId: widget.caseId),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildHearingListShimmerSkeleton() {
  return ListView.builder(
    padding: EdgeInsets.all(16.r),
    itemCount: 3, // Emulate standard list card counts
    itemBuilder: (context, index) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.grey.shade100, // Very quiet monochromatic surface tint
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140.w,
              height: 16.h,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r)),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              height: 12.h,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r)),
            ),
          ],
        ),
      );
    },
  );
}
