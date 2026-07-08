import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/client_resources/related_client_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/add_related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/related_client_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:uuid/uuid.dart';

import '../system_design/case_detail_theme.dart';

/// Opens the "Add Related Clients" bottom sheet. Reuses the three
/// ViewModels already provided higher up the tree (see
/// CaseDetailInfoScreenWrapper) rather than creating new ones — this is a
/// fire-and-forget sheet (nothing in the caller needs to react to how it
/// closes), so it doesn't need the Future-returning pattern the upload
/// sheet uses.
void showAddClientsSheet({
  required BuildContext context,
  required String caseId,
}) {
  context.read<RelatedClientViewModel>().resetSelectedClients();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: context.read<RelatedClientViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<AddRelatedClientViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<ClientListViewModel>()),
      ],
      child: _AddClientsSheet(caseId: caseId),
    ),
  );
}

class _AddClientsSheet extends StatefulWidget {
  final String caseId;
  const _AddClientsSheet({required this.caseId});
  @override
  State<_AddClientsSheet> createState() => _AddClientsSheetState();
}

class _AddClientsSheetState extends State<_AddClientsSheet> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ClientListViewModel>();
      if (vm.filterClients.isEmpty && !vm.isLoading) {
        vm.fetchClientList();
      }
    });
  }

  void _onScroll() {
    final vm = context.read<ClientListViewModel>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      if (vm.canLoadMore) vm.fetchClientList(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientVM = context.watch<ClientListViewModel>();
    final rcVM = context.watch<RelatedClientViewModel>();
    final addRcVM = context.watch<AddRelatedClientViewModel>();

    final selectable = clientVM.filterClients
        .where((c) => !rcVM.isClientAlreadyAdded(c.id))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: Container(
          decoration: BoxDecoration(
            color: RC.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 36.w,
                  height: 4,
                  decoration: BoxDecoration(
                      color: RC.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: 12.h),
              Text('Add Related Clients',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: RC.textPrimary)),
              Divider(color: RC.divider, height: 1),
              Expanded(
                child: clientVM.isLoading && selectable.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                            color: RC.navy, strokeWidth: 2))
                    : ListView.builder(
                        controller: _scroll,
                        itemCount: selectable.length +
                            (clientVM.isLoadingMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == selectable.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.r),
                                child: CircularProgressIndicator(
                                    color: RC.navy, strokeWidth: 2),
                              ),
                            );
                          }
                          final c = selectable[i];
                          return CheckboxListTile(
                            activeColor: RC.navy,
                            value: rcVM.isClientBoxIsChecked(c.id),
                            title: Text(c.name,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(c.phone.toString(),
                                style: TextStyle(
                                    fontSize: 12.sp, color: RC.textSecondary)),
                            onChanged: (v) => rcVM.onCheckBoxChange(v, c.id),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RC.navy,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    onPressed: rcVM.selectedClientsIds.isEmpty ||
                            addRcVM.loading
                        ? null
                        : () async {
                            final selected = clientVM.filterClients
                                .where((c) =>
                                    rcVM.selectedClientsIds.contains(c.id))
                                .map((c) => RelatedClientModel(
                                      id: 'temp_${const Uuid().v4()}',
                                      client: c,
                                      role: 'Evident',
                                      isSynced: false,
                                    ))
                                .toList();

                            rcVM.addRelatedClientsLocally(context, selected);
                            await rcVM.syncUnSyncedClients(context);
                            if (context.mounted) Navigator.pop(context);
                          },
                    child: addRcVM.loading
                        ? SizedBox(
                            height: 18.h,
                            width: 18.h,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Add Selected Clients',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Attached Clients" list rendered inline in the Case Detail screen's
/// build(). Moved here since it's related-client-specific UI, not general
/// case-detail chrome.
class RelatedClientsList extends StatelessWidget {
  final List<RelatedClientModel> relatedClients;
  const RelatedClientsList({super.key, required this.relatedClients});

  @override
  Widget build(BuildContext context) {
    if (relatedClients.isEmpty) {
      return Text('No related clients added.',
          style: TextStyle(fontSize: 13.sp, color: RC.textTertiary));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: relatedClients.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final rc = relatedClients[i];
        return RelatedClientInfoCard(
          isSynced: rc.isSynced,
          client: rc.client,
          onRemoveFromCase: () async {
            final vm = context.read<RelatedClientViewModel>();
            final ok = await vm.removeRelatedClient(context, rc);
            if (!context.mounted) return;
            SnakeBars.flutterToast(
              ok ? 'Client removed' : 'Failed to remove',
              context,
            );
          },
        );
      },
    );
  }
}
