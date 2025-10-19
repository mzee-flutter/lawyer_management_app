import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:right_case/resources/case_resources/case_info_card.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';

import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cases"),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300, shape: BoxShape.circle),
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
                          final clientCase = caseListVM.filterCases[index];
                          return InkWell(
                            child: CaseInfoCard(clientCase: clientCase),
                          );
                        } else {
                          // bottom loader
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade800,
        icon: const Icon(Icons.cases_rounded, color: Colors.white),
        label: const Text(
          'Add Case',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.addCaseScreen);
        },
      ),
    );
  }
}

/// just directly run the code to test that it return the list of cases..
