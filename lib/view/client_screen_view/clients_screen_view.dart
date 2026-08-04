import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/client_resources/client_info_card.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

import '../../resources/system_design/rc_theme.dart';
import '../../resources/system_design/rc_widgets.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    final clientListVM = context.read<ClientListViewModel>();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => clientListVM.fetchClientList());

    _scrollController.addListener(() {
      final vm = context.read<ClientListViewModel>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.85 &&
          vm.canLoadMore &&
          !vm.isLoading) {
        vm.fetchClientList(loadMore: true);
      }
      vm.handleScroll(_scrollController.position.userScrollDirection);
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
        backgroundColor: RC.background,
        appBar: _buildAppBar(context),
        body: Consumer<ClientListViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && vm.filterClients.isEmpty) {
              return const _ClientsSkeleton();
            }

            final displayClient = vm.filterClients;

            // Real failure, nothing to show -- separate from "list is
            // genuinely empty," which gets its own widget below.
            if (vm.hasError && displayClient.isEmpty) {
              return RCErrorState(
                message: vm.errorMessage!,
                onRetry: () => vm.fetchClientList(),
              );
            }

            if (displayClient.isEmpty) {
              return RCEmptyState(
                icon: Icons.group_off_outlined,
                title: 'No Clients Found',
                message: vm.searchController.text.isNotEmpty
                    ? 'Try a different name or number.'
                    : 'Tap "Add Client" to create your first client.',
              );
            }

            return RefreshIndicator(
              color: RC.navy,
              backgroundColor: RC.surface,
              strokeWidth: 2,
              onRefresh: () async {
                await vm.refresh();
                if (!context.mounted) return;
                // Existing data stays on screen regardless -- a failed
                // refresh shouldn't nuke a perfectly good cached list, it
                // just needs to say so.
                SnakeBars.flutterToast(
                  vm.hasError
                      ? (vm.errorMessage ?? 'Refresh failed. Please try again.')
                      : 'Clients refreshed',
                  context,
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                itemCount: displayClient.length + (vm.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < displayClient.length) {
                    final client = displayClient[index];
                    return ClientInfoCard(client: client);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: vm.isLoadingMore
                          ? CircularProgressIndicator(
                              color: RC.navy, strokeWidth: 2)
                          : vm.hasError
                              ? TextButton.icon(
                                  onPressed: () =>
                                      vm.fetchClientList(loadMore: true),
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
        floatingActionButton: Selector<ClientListViewModel, bool>(
          selector: (_, vm) => vm.isButtonIsVisible,
          builder: (context, isVisible, __) => AnimatedSlide(
            offset: isVisible ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: FloatingActionButton.extended(
                backgroundColor: RC.navy,
                icon:
                    const Icon(Icons.person_add_outlined, color: Colors.white),
                label: Text('Add Client',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5.sp)),
                onPressed: () => context.pushNamed(RoutesName.addClientScreen),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final clientListVM = context.read<ClientListViewModel>();
    return AppBar(
      backgroundColor: RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: _showSearch
          ? TextField(
              focusNode: clientListVM.searchFocusNode,
              controller: clientListVM.searchController,
              autofocus: true,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search clients…',
                hintStyle:
                    TextStyle(color: RC.textOnDarkMuted, fontSize: 15.sp),
                border: InputBorder.none,
              ),
            )
          : Consumer<ClientListViewModel>(
              builder: (_, vm, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clients',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (vm.filterClients.isNotEmpty)
                    Text(
                      '${vm.filterClients.length} active',
                      style:
                          TextStyle(fontSize: 11.sp, color: RC.textOnDarkMuted),
                    ),
                ],
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              // ClientListViewModel's own controller listener keeps
              // _searchQuery in sync now, so a plain .clear() is enough --
              // no separate setSearchQuery('') call needed anymore.
              if (!_showSearch) clientListVM.searchController.clear();
            });
          },
        ),
      ],
    );
  }
}

class _ClientsSkeleton extends StatelessWidget {
  const _ClientsSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 118.h,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: RC.divider),
        ),
      ),
    );
  }
}
