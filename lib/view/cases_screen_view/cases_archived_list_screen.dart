import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/case_resources/archived_case_card.dart';
import 'package:right_case/resources/client_resources/archived_client_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_archived_list_view_model.dart';

import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';

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
    final caseListVM =
        Provider.of<CaseArchivedListViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      caseListVM.fetchArchivedCases();
    });
  }

  bool _isScrollNearToEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        (scrollInfo.metrics.maxScrollExtent * .85);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.grey.shade300,
        title: const Text("Archive Cases"),
      ),
      body: Consumer<CaseArchivedListViewModel>(
        builder: (BuildContext context, caseArchiveListVM, Widget? child) {
          if (caseArchiveListVM.isFirstLoading) {
            // Show full loader on first fetch
            return Center(
              child: CircularProgressIndicator(
                color: Colors.grey.shade700,
                strokeWidth: 2,
              ),
            );
          }

          if (caseArchiveListVM.archiveCaseList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: const Text(
                  "No archived cases found.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (_isScrollNearToEnd(scrollInfo)) {
                if (!caseArchiveListVM.isMoreLoading &&
                    caseArchiveListVM.hasMore) {
                  caseArchiveListVM.fetchArchivedCases(loadMore: true);
                }
              }
              return false;
            },
            child: RefreshIndicator(
              color: Colors.grey.shade700,
              backgroundColor: Colors.white,
              strokeWidth: 2.w,
              onRefresh: () async {
                await caseArchiveListVM.fetchArchivedCases(
                  loadMore: false,
                  isRefresh: true,
                );
                if (context.mounted) {
                  SnakeBars.flutterToast("cases Refreshed", context);
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.all(12.r),
                itemCount: caseArchiveListVM.archiveCaseList.length +
                    (caseArchiveListVM.isMoreLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < caseArchiveListVM.archiveCaseList.length) {
                    final caseData = caseArchiveListVM.archiveCaseList[index];
                    return ArchivedCaseCard(caseData: caseData);
                  } else {
                    // Loader at bottom for loadMore
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade700,
                          strokeWidth: 2.w,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
