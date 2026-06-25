import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/case_resources/case_info_card.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/cases_screen_view/case_detail_info_screen_view.dart';
import 'package:right_case/view/cases_screen_view/case_update_screen_view.dart';
import 'package:right_case/view/home_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_archive_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_permanent_delete_view_model.dart';

class CasesListScreen extends StatefulWidget {
  @override
  State<CasesListScreen> createState() => CasesListScreenState();
  const CasesListScreen({super.key});
}

class CasesListScreenState extends State<CasesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final casesVM = Provider.of<CaseListViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      casesVM.fetchCaseList();
    });

    ///This is another way to control the scrolling and fetching more clients
    ///We have another way of doing this in ClientArchivedListScreen both works same.
    _scrollController.addListener(() {
      final vm = Provider.of<CaseListViewModel>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.85 &&
          !vm.isLoadingMore &&
          vm.hasMore &&
          !vm.isLoading) {
        vm.fetchCaseList(loadMore: true);
      }
      vm.handleScroll(_scrollController.position.userScrollDirection);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              builder: (_) => HomeScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Cases",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.shade300,
        ),
        body: Consumer<CaseListViewModel>(
          builder: (BuildContext context, caseListVM, Widget? child) {
            return Column(
              children: [
                if (caseListVM.isLoading && caseListVM.filterCases.isEmpty)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade700,
                        strokeWidth: 2.w,
                      ),
                    ),
                  )
                else if (caseListVM.filterCases.isEmpty)
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle),
                        child: Icon(
                          Icons.report_problem_rounded,
                          size: 40,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Cases Not Found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.grey.shade700,
                      backgroundColor: Colors.white,
                      strokeWidth: 2.w,
                      onRefresh: () async {
                        await caseListVM.fetchCaseList(
                          loadMore: false,
                          isRefresh: true,
                        );
                        if (context.mounted) {
                          SnakeBars.flutterToast("Cases Refreshed", context);
                        }
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: caseListVM.filterCases.length +
                            (caseListVM.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < caseListVM.filterCases.length) {
                            final caseData = caseListVM.filterCases[index];
                            return CaseInfoCard(
                              caseData: caseData,
                              onDelete: () {
                                showDeleteCaseDialog(
                                  context: context,
                                  caseData: caseData,
                                );
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CaseUpdateScreenView(
                                        caseData: caseData),
                                  ),
                                );
                              },
                              onView: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CaseDetailInfoScreenWrapper(
                                      caseId: caseData.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.r),
                              child: Center(
                                child: caseListVM.isLoadingMore
                                    ? CircularProgressIndicator(
                                        color: Colors.grey.shade700,
                                        strokeWidth: 2,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: Selector<CaseListViewModel, bool>(
          selector: (_, vm) => vm.isButtonIsVisible,
          builder: (context, isVisible, child) {
            return AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.grey.shade800,
                  icon: const Icon(Icons.cases_rounded, color: Colors.white),
                  label: const Text(
                    'Add Case',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.caseCreateScreen);
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

void showDeleteCaseDialog(
    {required BuildContext context, required CaseModel caseData}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey.shade300,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        content: Consumer2<CaseArchiveViewModel, CasePermanentDeleteViewModel>(
          builder: (context, caseArchiveVM, casePermanentDeleteVM, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Delete Case',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Are you sure you want to delete this case ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _deleteConformationButtons(
                      title: "Cancel",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10.w),
                    _deleteConformationButtons(
                      title: "Archive",
                      color: Colors.orangeAccent,
                      onTap: () async {
                        await caseArchiveVM.archiveCase(
                          context,
                          caseData.id,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        context.read<CaseListViewModel>().unFocusSearch();
                      },
                    ),
                    SizedBox(width: 10.w),
                    _deleteConformationButtons(
                      title: "Delete",
                      color: Colors.red,
                      onTap: () async {
                        await casePermanentDeleteVM.deleteCasePermanent(
                            context, caseData.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Widget _deleteConformationButtons({
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Container(
    height: 40.h,
    width: 75.w,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(50),
    ),
    child: InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
