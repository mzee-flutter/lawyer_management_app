import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/client_resources/client_info_card.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final clientListVM =
        Provider.of<ClientListViewModel>(context, listen: false);

    // initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clientListVM.fetchClientList();
    });

    ///This is another way to control the scrolling and fetching more clients
    ///We have another way of doing this in ClientArchivedListScreen both works same.
    _scrollController.addListener(() {
      final vm = Provider.of<ClientListViewModel>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.85 &&
          !vm.isLoadingMore &&
          vm.hasMore &&
          !vm.isLoading) {
        vm.fetchClientList(loadMore: true);
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          backgroundColor: Colors.grey.shade300,
          title: const Text('Clients'),
        ),
        body: Consumer<ClientListViewModel>(
          builder: (BuildContext context, clientListVM, Widget? child) {
            return Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                children: [
                  // Search field
                  TextField(
                    focusNode: clientListVM.searchFocusNode,
                    autofocus: false,
                    controller: clientListVM.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Clients...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade700, width: 1.5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onChanged: (value) => clientListVM.setSearchQuery(value),
                    cursorColor: Colors.grey.shade700,
                  ),

                  SizedBox(height: 12.h),

                  // Content area
                  if (clientListVM.isLoading &&
                      clientListVM.filterClients.isEmpty)
                    // first-time loader
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade700,
                          strokeWidth: 2.w,
                        ),
                      ),
                    )
                  else if (clientListVM.filterClients.isEmpty)
                    // empty state
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 100.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.group_off_outlined,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Client Not Found',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // list with bottom loader for pagination
                    Expanded(
                      child: RefreshIndicator(
                        color: Colors.grey.shade700,
                        backgroundColor: Colors.white,
                        strokeWidth: 2.w,
                        onRefresh: () async {
                          await clientListVM.fetchClientList(loadMore: false);
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: clientListVM.filterClients.length +
                              (clientListVM.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < clientListVM.filterClients.length) {
                              final client = clientListVM.filterClients[index];
                              return ClientInfoCard(client: client);
                            } else {
                              // bottom loader
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.r),
                                child: Center(
                                  child: clientListVM.isLoadingMore
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
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.grey.shade800,
          onPressed: () {
            Navigator.pushNamed(context, RoutesName.addClientScreen);
          },
          icon: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
          label: const Text(
            'Add Client',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
