import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/case_resources/case_file_section_view.dart';
import 'package:right_case/resources/client_resources/related_client_info_card.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/add_case_file_view_model.dart';
import 'package:right_case/view_model/cases_view_model/add_related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_service_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/remove_case_file_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:uuid/uuid.dart';

class CaseDetailInfoScreenWrapper extends StatelessWidget {
  final String caseId;
  const CaseDetailInfoScreenWrapper({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CaseFilesViewModel(caseId: caseId)),
        ChangeNotifierProvider(create: (_) => AddCaseFileViewModel()),
        ChangeNotifierProvider(create: (_) => RemoveCaseFileViewModel()),
        ChangeNotifierProvider(create: (_) => CaseFilesServiceViewModel()),
        ChangeNotifierProvider(
            create: (_) => RelatedClientViewModel(caseId: caseId)),
        ChangeNotifierProvider(create: (_) => AddRelatedClientViewModel()),
      ],
      child: CaseDetailInfoScreenView(caseId: caseId),
    );
  }
}

class CaseDetailInfoScreenView extends StatefulWidget {
  final String caseId;

  const CaseDetailInfoScreenView({
    super.key,
    required this.caseId,
  });

  @override
  State<CaseDetailInfoScreenView> createState() =>
      _CaseDetailInfoScreenViewState();
}

class _CaseDetailInfoScreenViewState extends State<CaseDetailInfoScreenView> {
  bool _isUploadSheetOpen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final relatedClientVM = context.read<RelatedClientViewModel>();

      context.read<CaseFilesViewModel>().loadFilesFromCase(context);

      relatedClientVM.loadRelatedClientsFromCase(context);
      relatedClientVM.syncUnSyncedClients(context);
    });
  }

  void _openUploadSheet(AddCaseFileViewModel vm) {
    if (_isUploadSheetOpen) return;

    _isUploadSheetOpen = true;

    _showUploadBottomSheet(
      context: context,
      caseId: widget.caseId,
      caseFilesVM: context.read<CaseFilesViewModel>(),
    );
  }

  void _closeUploadSheet() {
    if (!_isUploadSheetOpen) return;

    _isUploadSheetOpen = false;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final caseData =
        context.watch<CaseListViewModel>().getCaseById(widget.caseId);
    final hasUnSyncedClient =
        context.read<RelatedClientViewModel>().relatedClients.any(
              (rc) => !rc.isSynced,
            );
    final formattedDate =
        DateFormat('dd MMM, yyyy').format(caseData!.registrationDate);

    return Consumer<AddCaseFileViewModel>(builder: (context, addCaseFileVM, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        /// OPEN bottom sheet
        if (addCaseFileVM.status == UploadStatus.readyToUpload) {
          _openUploadSheet(addCaseFileVM);
        }

        if (addCaseFileVM.status == UploadStatus.idle && _isUploadSheetOpen) {
          _closeUploadSheet();
        }

        /// SUCCESS
        if (addCaseFileVM.status == UploadStatus.success) {
          _closeUploadSheet();

          SnakeBars.flutterToast(
            "Files uploaded successfully",
            context,
          );

          addCaseFileVM.cancelUploadWorkflow();
        }

        /// ERROR
        if (addCaseFileVM.status == UploadStatus.error) {
          _closeUploadSheet();
          SnakeBars.flutterToast(
            addCaseFileVM.error ?? "Upload failed",
            context,
          );
          addCaseFileVM.cancelUploadWorkflow();
        }
      });

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          title: Text(
            "Case Preview",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () {
                  // TODO: Generate PDF
                },
                icon: const Icon(Icons.picture_as_pdf_outlined,
                    size: 18, color: Colors.black),
                label: const Text(
                  "Generate PDF",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Case Number: #${caseData.caseNumber}",
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 10.h),
              Center(
                child: Text(
                  caseData.firstPartyName,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 14.h),

              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _action(
                      icon: Icons.person_add_alt_1_outlined,
                      label: "Add Client",
                      onTap: () {
                        showAddRelatedClientsSheet(
                          context: context,
                          caseId: caseData.id,
                        );
                      },
                    ),
                    _action(
                      icon: Icons.file_copy_outlined,
                      label: "Add Files",
                      onTap: () {
                        context.read<AddCaseFileViewModel>().pickFiles();
                      },
                    ),
                    _action(
                      icon: Icons.event_available_outlined,
                      label: "Hearings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HearingListScreenView(
                              caseId: caseData.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              _sectionHeader("Case Basic Information",
                  trailing: "Sticky Notes"),
              _infoTile(Icons.calendar_today_outlined,
                  "Register Date: $formattedDate"),
              _infoTile(Icons.confirmation_number_outlined,
                  "Case Number: ${caseData.caseNumber}"),
              _infoTile(Icons.category_outlined,
                  "Case Type: ${caseData.caseType?.name ?? 'Not Added'}"),
              _infoTile(Icons.layers_outlined,
                  "Case Stage: ${caseData.caseStage?.name ?? 'Not Added'}"),
              _infoTile(Icons.flag_outlined,
                  "Case Status: ${caseData.caseStatus?.name ?? 'Not Added'}"),
              // _infoTile(Icons.price_change_outlined,
              //     "Legal Fees: ${caseData.legalFees?.toStringAsFixed(0) ?? 'N/A'}"),

              SizedBox(height: 18.h),

              _dropdownTile(
                  "Case Study", caseData.caseNotes ?? "No notes added."),

              SizedBox(height: 22.h),

              _sectionTitle("Court Information"),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _courtCard(Icons.balance_rounded, "Court Category",
                      caseData.courtCategory?.name ?? "N/A"),
                  _courtCard(Icons.account_balance_rounded, "Court Name",
                      caseData.courtName ?? "N/A"),
                  _courtCard(Icons.person_outline_rounded, "Judge",
                      caseData.judgeName ?? "N/A"),
                ],
              ),

              SizedBox(height: 24.h),

              _sectionTitle("Other Information"),
              Consumer<CaseFilesViewModel>(
                builder: (context, caseFilesVM, child) {
                  return CaseFilesEmbeddedSection(
                    files: caseFilesVM.files,
                  );
                },
              ),
              _iconInfo(Icons.calendar_month_outlined, "Created At",
                  DateFormat('dd MMM, yyyy').format(caseData.createdAt)),
              if (caseData.updatedAt != null)
                _iconInfo(Icons.update, "Last Updated",
                    DateFormat('dd MMM, yyyy').format(caseData.updatedAt!)),
              Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Attached Clients"),
                  Consumer<RelatedClientViewModel>(
                    builder: (context, relatedClientVM, _) {
                      if (!hasUnSyncedClient) return SizedBox();

                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: relatedClientVM.isSyncing
                            ? null
                            : () async {
                                final success = await relatedClientVM
                                    .syncUnSyncedClients(context);
                                if (!context.mounted) return;

                                if (success) {
                                  SnakeBars.flutterToast(
                                    "All clients synced successfully",
                                    context,
                                  );
                                } else {
                                  SnakeBars.flutterToast(
                                    relatedClientVM.lastError ?? "Sync failed",
                                    context,
                                  );
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: relatedClientVM.isSyncing
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: relatedClientVM.isSyncing
                              ? SizedBox(
                                  height: 18.h,
                                  width: 18.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey.shade900,
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  color: Colors.grey.shade900,
                                  size: 20,
                                ),
                        ),
                      );
                    },
                  )
                ],
              ),
              Consumer<RelatedClientViewModel>(
                builder: (context, relatedClientVM, _) {
                  return _relatedClientsSection(
                    relatedClients: relatedClientVM.relatedClients,
                  );
                },
              ),

              SizedBox(height: 80.h),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.sp),
              borderSide: BorderSide.none),
          backgroundColor: Colors.grey.shade800,
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (_) => EditCaseScreen(clientCase: caseData)),
            // );
          },
          icon: Icon(Icons.edit_outlined, color: Colors.grey.shade300),
          label:
              Text("Edit Case", style: TextStyle(color: Colors.grey.shade300)),
        ),
      );
    });
  }

  // ---------- Reusable UI Components ----------

  Widget _action(
          {required IconData icon,
          required String label,
          required void Function() onTap}) =>
      InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.grey.shade900),
            ),
            SizedBox(height: 6.h),
            Text(label,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 13)),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
      );

  Widget _sectionHeader(String text, {String? trailing}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionTitle(text),
          if (trailing != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade700,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_outlined,
                      size: 16, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(trailing,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      );

  Widget _infoTile(IconData icon, String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey.shade900),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _dropdownTile(String title, String content) => Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10.r),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.grey.shade300,
          backgroundColor: Colors.grey.shade300,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none),
          collapsedShape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(content,
                  style:
                      TextStyle(color: Colors.grey.shade900, fontSize: 14.sp)),
            ),
          ],
        ),
      );

  Widget _courtCard(IconData icon, String label, String value) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 20.sp),
            SizedBox(
              width: 10.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade700)),
                SizedBox(height: 3.w),
                Text(value,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      );

  Widget _iconInfo(IconData icon, String title, String value) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(icon, color: Colors.grey.shade900, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.sp)),
                  Text(value,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13.sp)),
                ],
              ),
            ),
          ],
        ),
      );
}

///-----------------------------------///

void _showUploadBottomSheet({
  required BuildContext context,
  required String caseId,
  required CaseFilesViewModel caseFilesVM,
}) {
  final addCaseFileVM = context.read<AddCaseFileViewModel>();

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return ChangeNotifierProvider.value(
        value: addCaseFileVM,
        child: _UploadBottomSheet(
          caseId: caseId,
          caseFilesVM: caseFilesVM,
        ),
      );
    },
  );
}

class _UploadBottomSheet extends StatelessWidget {
  final String caseId;
  final CaseFilesViewModel caseFilesVM;

  const _UploadBottomSheet({
    required this.caseId,
    required this.caseFilesVM,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddCaseFileViewModel>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHeader(),
          const SizedBox(height: 12),
          _FileList(vm: vm),
          const SizedBox(height: 20),
          _SheetActions(
            addCaseFileVM: vm,
            caseId: caseId,
            caseFilesVM: caseFilesVM,
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 6),
        Text(
          "Uploading Files",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FileList extends StatelessWidget {
  final AddCaseFileViewModel vm;

  const _FileList({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.selectedFiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "No files selected",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: vm.selectedFiles.map((file) {
        return ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(
            file.file.path.split('/').last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: vm.status == UploadStatus.uploading
              ? LinearProgressIndicator(value: file.progress)
              : null,
          trailing: vm.status == UploadStatus.uploading
              ? Text("${(file.progress * 100).toInt()}%")
              : const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
        );
      }).toList(),
    );
  }
}

class _SheetActions extends StatelessWidget {
  final AddCaseFileViewModel addCaseFileVM;
  final String caseId;
  final CaseFilesViewModel caseFilesVM;

  const _SheetActions({
    required this.addCaseFileVM,
    required this.caseId,
    required this.caseFilesVM,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              disabledForegroundColor: Colors.white,
            ),
            onPressed: addCaseFileVM.status == UploadStatus.uploading
                ? null
                : () {
                    context.read<AddCaseFileViewModel>().cancelUploadWorkflow();
                  },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
              ),
              onPressed: addCaseFileVM.status == UploadStatus.uploading
                  ? null
                  : () async {
                      final uploadedFiles =
                          await addCaseFileVM.uploadFiles(caseId);

                      caseFilesVM.addFile(context, uploadedFiles);
                    },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity:
                        addCaseFileVM.status == UploadStatus.uploading ? 0 : 1,
                    child: Text(
                      "Upload Files",
                      style: TextStyle(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  if (addCaseFileVM.status == UploadStatus.uploading)
                    SizedBox(
                      height: 17.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///-----------------------------------------------///

Widget _relatedClientsSection(
    {required List<RelatedClientModel> relatedClients}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 10.h),
      if (relatedClients.isEmpty)
        Text(
          "No related clients added",
          style: TextStyle(color: Colors.grey),
        )
      else
        ListView.builder(
          itemCount: relatedClients.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final relatedClient = relatedClients[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 12.0.h),
              child: RelatedClientInfoCard(
                isSynced: relatedClient.isSynced,
                client: relatedClient.client,
                onRemoveFromCase: () async {
                  final relatedClientVM =
                      context.read<RelatedClientViewModel>();

                  final success = await relatedClientVM.removeRelatedClient(
                    context,
                    relatedClient,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    SnakeBars.flutterToast(
                      "Client removed successfully",
                      context,
                    );
                  } else {
                    SnakeBars.flutterToast(
                      "Failed to remove client",
                      context,
                    );
                  }
                },
              ),
            );
          },
        ),
    ],
  );
}

///---------------------------------///
void showAddRelatedClientsSheet({
  required BuildContext context,
  required String caseId,
}) {
  context.read<RelatedClientViewModel>().resetSelectedClients();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: context.read<RelatedClientViewModel>(),
          ),
          ChangeNotifierProvider.value(
            value: context.read<AddRelatedClientViewModel>(),
          ),
          ChangeNotifierProvider.value(
            value: context.read<ClientListViewModel>(),
          ),
        ],
        child: _AddRelatedClientsSheet(caseId: caseId),
      );
    },
  );
}

class _AddRelatedClientsSheet extends StatefulWidget {
  final String caseId;
  const _AddRelatedClientsSheet({required this.caseId});

  @override
  State<_AddRelatedClientsSheet> createState() =>
      _AddRelatedClientsSheetState();
}

class _AddRelatedClientsSheetState extends State<_AddRelatedClientsSheet> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    /// 🔹 Fetch clients ONLY if not fetched yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientVM = context.read<ClientListViewModel>();
      if (clientVM.filterClients.isEmpty && !clientVM.isLoading) {
        clientVM.fetchClientList();
      }
    });
  }

  void _onScroll() {
    final clientVM = context.read<ClientListViewModel>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (clientVM.canLoadMore) {
        clientVM.fetchClientList(loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientVM = context.watch<ClientListViewModel>();
    final relatedClientVM = context.watch<RelatedClientViewModel>();
    final addRelatedClientVM = context.watch<AddRelatedClientViewModel>();

    final selectableClients = clientVM.filterClients
        .where((c) => !relatedClientVM.isClientAlreadyAdded(c.id))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 90.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Text(
                "Add Related Clients",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),

              /// 🔹 LIST
              Expanded(
                child: clientVM.isLoading && selectableClients.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade700,
                          strokeWidth: 2,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: selectableClients.length +
                            (clientVM.isLoadingMore ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index == selectableClients.length) {
                            return Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          }

                          final client = selectableClients[index];

                          return CheckboxListTile(
                            activeColor: Colors.grey.shade700,
                            value:
                                relatedClientVM.isClientBoxIsChecked(client.id),
                            title: Text(client.name),
                            subtitle: Text(client.phone.toString()),
                            onChanged: (val) {
                              relatedClientVM.onCheckBoxChange(
                                val,
                                client.id,
                              );
                            },
                          );
                        },
                      ),
              ),

              /// 🔹 ACTION BUTTON
              Padding(
                padding: EdgeInsets.all(12.r),
                child: SizedBox(
                  height: 35.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                    ),
                    onPressed: relatedClientVM.selectedClientsIds.isEmpty ||
                            addRelatedClientVM.loading
                        ? null
                        : () async {
                            final selected = clientVM.filterClients
                                .where((c) => relatedClientVM.selectedClientsIds
                                    .contains(c.id))
                                .map(
                                  (c) => RelatedClientModel(
                                    id: "temp_${const Uuid().v4()}",
                                    client: c,
                                    role: "Evident",
                                    isSynced: false,
                                  ),
                                )
                                .toList();

                            /// instant UX
                            relatedClientVM.addRelatedClientsLocally(
                              context,
                              selected,
                            );

                            /// sync
                            await relatedClientVM.syncUnSyncedClients(context);

                            if (context.mounted) Navigator.pop(context);
                          },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (addRelatedClientVM.loading)
                          SizedBox(
                            height: 17.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Text(
                            "Add Selected Clients",
                            style: TextStyle(color: Colors.white),
                          ),
                      ],
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
