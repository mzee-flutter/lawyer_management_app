import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/client_resources/archived_client_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';

import '../../resources/system_design/rc_theme.dart';
import '../../resources/system_design/rc_widgets.dart';

class ClientArchivedListScreen extends StatefulWidget {
  const ClientArchivedListScreen({super.key});
  @override
  State<ClientArchivedListScreen> createState() =>
      _ClientArchivedListScreenState();
}

class _ClientArchivedListScreenState extends State<ClientArchivedListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientArchivedListViewModel>().fetchArchivedClients();
    });
  }

  bool _nearEnd(ScrollNotification n) =>
      n.metrics.pixels >= n.metrics.maxScrollExtent * 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.background,
      appBar: AppBar(
        backgroundColor: RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: RC.textOnDark),
        title: Consumer<ClientArchivedListViewModel>(
          builder: (_, vm, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Archived Clients',
                  style: TextStyle(
                      color: RC.textOnDark,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700)),
              if (vm.archiveClientList.isNotEmpty)
                Text('${vm.archiveClientList.length} archived',
                    style:
                        TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
      body: Consumer<ClientArchivedListViewModel>(
        builder: (context, vm, __) {
          if (vm.isFirstLoading) return const _Skeleton();

          if (vm.archiveClientList.isEmpty) {
            return const RCEmptyState(
              icon: Icons.archive_outlined,
              title: 'No Archived Clients',
              message:
                  'Clients you archive will appear here and can be restored anytime.',
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (_nearEnd(n) && !vm.isMoreLoading && vm.hasMore) {
                vm.fetchArchivedClients(loadMore: true);
              }
              return false;
            },
            child: RefreshIndicator(
              color: RC.navy,
              backgroundColor: RC.surface,
              strokeWidth: 2,
              onRefresh: () async {
                await vm.fetchArchivedClients(loadMore: false, isRefresh: true);
                if (context.mounted) {
                  SnakeBars.flutterToast('Clients refreshed', context);
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    vm.archiveClientList.length + (vm.isMoreLoading ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index < vm.archiveClientList.length) {
                    return ArchivedClientInfoCard(
                        client: vm.archiveClientList[index]);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: RC.navy, strokeWidth: 2)),
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

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 150.h,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
            color: RC.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: RC.divider)),
      ),
    );
  }
}
