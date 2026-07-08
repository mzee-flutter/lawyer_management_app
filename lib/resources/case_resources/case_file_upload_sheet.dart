import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view_model/cases_view_model/add_case_file_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';

import '../system_design/case_detail_theme.dart';

/// Opens the file-upload bottom sheet and returns the underlying route's
/// Future, which completes the instant the sheet is removed from the
/// navigator — by any means (Cancel, back press, or a completed upload).
/// The caller chains `.then()` on this directly to know when the sheet is
/// gone, instead of relying on shared/global mutable state.
Future<void> showUploadSheet({
  required BuildContext context,
  required String caseId,
  required CaseFilesViewModel filesVM,
}) {
  final addVM = context.read<AddCaseFileViewModel>();
  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: addVM,
      child: _UploadSheet(caseId: caseId, filesVM: filesVM),
    ),
  );
}

class _UploadSheet extends StatelessWidget {
  final String caseId;
  final CaseFilesViewModel filesVM;
  const _UploadSheet({required this.caseId, required this.filesVM});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddCaseFileViewModel>();

    return PopScope(
      // Every dismissal path — hardware back, predictive back gesture, or
      // anything else that would pop this route — funnels through the same
      // teardown as the Cancel button: stop the network request, clear
      // state, then actually close the sheet. Nothing can bypass this.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        context.read<AddCaseFileViewModel>().cancelUploadWorkflow();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16.w, 16.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
        decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                    color: RC.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Icon(Icons.upload_file_outlined, size: 20.sp, color: RC.navy),
                SizedBox(width: 8.w),
                Text('Uploading Files',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: RC.textPrimary)),
              ],
            ),
            SizedBox(height: 14.h),
            if (vm.selectedFiles.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text('No files selected',
                    style: TextStyle(color: RC.textTertiary)),
              )
            else
              Column(
                children: vm.selectedFiles.map((f) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: RC.background,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: RC.divider, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insert_drive_file_outlined,
                                size: 16.sp, color: RC.navy),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                f.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.sp, color: RC.textPrimary),
                              ),
                            ),
                            if (vm.status != UploadStatus.uploading)
                              Icon(Icons.check_circle_outline,
                                  size: 16.sp, color: RC.successText)
                            else
                              Text(
                                '${(f.progress * 100).toInt()}%',
                                style:
                                    TextStyle(fontSize: 11.sp, color: RC.navy),
                              ),
                          ],
                        ),
                        if (vm.status == UploadStatus.uploading)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: LinearProgressIndicator(
                              value: f.progress,
                              backgroundColor: RC.divider,
                              valueColor: AlwaysStoppedAnimation(RC.navy),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      side: BorderSide(color: RC.divider),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    // Always enabled, even mid-upload — cancelling actually
                    // aborts the network request via CancelToken.
                    onPressed: () => context
                        .read<AddCaseFileViewModel>()
                        .cancelUploadWorkflow(),
                    child: Text(
                      vm.status == UploadStatus.uploading
                          ? 'Cancel Upload'
                          : 'Cancel',
                      style: TextStyle(color: RC.textSecondary),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RC.navy,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    onPressed: (vm.status == UploadStatus.uploading ||
                            vm.selectedFiles.isEmpty)
                        ? null
                        : () async {
                            final uploaded = await vm.uploadFiles(caseId);
                            if (context.mounted) {
                              filesVM.addFile(context, uploaded);
                            }
                          },
                    child: vm.status == UploadStatus.uploading
                        ? SizedBox(
                            height: 18.h,
                            width: 18.h,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Upload',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
