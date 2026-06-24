import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/client_resources/archived_client_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';

import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';

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
    final clientArchivedListVM = context.read<ClientArchivedListViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clientArchivedListVM.fetchArchivedClients();
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
        title: const Text("Archive Clients"),
      ),
      body: Consumer<ClientArchivedListViewModel>(
        builder: (BuildContext context, clientArchivedListVM, Widget? child) {
          if (clientArchivedListVM.isFirstLoading) {
            // Show full loader on first fetch
            return Center(
              child: CircularProgressIndicator(
                color: Colors.grey.shade700,
                strokeWidth: 2,
              ),
            );
          }

          if (clientArchivedListVM.archiveClientList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: const Text(
                  "No archived clients found.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (_isScrollNearToEnd(scrollInfo)) {
                if (!clientArchivedListVM.isMoreLoading &&
                    clientArchivedListVM.hasMore) {
                  clientArchivedListVM.fetchArchivedClients(loadMore: true);
                }
              }
              return false;
            },
            child: RefreshIndicator(
              color: Colors.grey.shade700,
              backgroundColor: Colors.white,
              strokeWidth: 2.w,
              onRefresh: () async {
                await clientArchivedListVM.fetchArchivedClients(
                  loadMore: false,
                  isRefresh: true,
                );
                if (context.mounted) {
                  SnakeBars.flutterToast("Clients Refreshed", context);
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.all(12.r),
                itemCount: clientArchivedListVM.archiveClientList.length +
                    (clientArchivedListVM.isMoreLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < clientArchivedListVM.archiveClientList.length) {
                    final client =
                        clientArchivedListVM.archiveClientList[index];
                    return ArchivedClientInfoCard(client: client);
                  } else {
                    // Loader at bottom for loadMore
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade700,
                          strokeWidth: 2,
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
