import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_files_service_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';
import 'package:right_case/view_model/cases_view_model/remove_case_file_view_model.dart';

import '../../resources/system_design/rc_theme.dart';

class CaseAllFilesScreenView extends StatelessWidget {
  const CaseAllFilesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final filesVM = context.watch<CaseFilesViewModel>();
    final serviceVM = context.watch<CaseFilesServiceViewModel>();
    final removeVM = context.read<RemoveCaseFileViewModel>();

    final files = filesVM.files;

    return Scaffold(
      backgroundColor: RC.background,
      appBar: AppBar(
        backgroundColor: RC.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: RC.textOnDark),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Case Files',
                style: TextStyle(
                    color: RC.textOnDark,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700)),
            Text('${files.length} file${files.length == 1 ? '' : 's'}',
                style: TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp)),
          ],
        ),
      ),
      body: files.isEmpty
          ? const Center(child: Text("No files uploaded"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) {
                final file = files[index];
                final state = serviceVM.getFileState(file.filename);

                return CaseFileCard(
                  file: file,
                  state: state,
                  caseFilesServiceVM: serviceVM,
                  caseFilesVM: filesVM,
                  removeCaseFileVM: removeVM,
                );
              },
            ),
    );
  }
}

class CaseFileCard extends StatelessWidget {
  final CaseFileModel file;
  final FileLoadState state;
  final CaseFilesServiceViewModel caseFilesServiceVM;
  final CaseFilesViewModel caseFilesVM;
  final RemoveCaseFileViewModel removeCaseFileVM;

  const CaseFileCard({
    super.key,
    required this.file,
    required this.state,
    required this.caseFilesServiceVM,
    required this.caseFilesVM,
    required this.removeCaseFileVM,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      color: RC.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: state == FileLoadState.loading
            ? null
            : () => caseFilesServiceVM.openFile(context, file),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FileIcon(filename: file.filename),

                  const SizedBox(width: 12),

                  /// FILE INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.filename,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RC.body().copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Uploaded • ${DateFormat('dd MMM yyyy').format(file.uploadedAt)}",
                          style: RC.caption().copyWith(
                                color: RC.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),

                  /// DELETE
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () {
                      _confirmDelete(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// FOOTER
              Row(
                children: [
                  if (state == FileLoadState.loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    state == FileLoadState.loading
                        ? "Opening file..."
                        : "Tap to view",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: RC.surface,
        content: Column(
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
              "Are you sure you want to delete this file?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _deleteConformationButtons(
                    title: "Cancel",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _deleteConformationButtons(
                    title: "Delete",
                    color: Colors.red,
                    onTap: () async {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      try {
                        final removedFile =
                            await removeCaseFileVM.removeFileFromCase(file.id);
                        caseFilesVM.removeFile(context, removedFile.id);

                        SnakeBars.flutterToast(
                          "File removed successfully",
                          context,
                        );
                      } catch (e) {
                        SnakeBars.flutterToast(
                          "Failed to remove file",
                          context,
                        );
                      }
                    },
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

class _FileIcon extends StatelessWidget {
  final String filename;

  const _FileIcon({required this.filename});

  @override
  Widget build(BuildContext context) {
    final lower = filename.toLowerCase();

    IconData icon;
    Color color;

    if (lower.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red.shade600;
    } else if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png')) {
      icon = Icons.image_rounded;
      color = Colors.blue.shade600;
    } else if (lower.endsWith('.pptx') || lower.endsWith('.ppt')) {
      icon = FontAwesomeIcons.solidFilePowerpoint;
      color = Colors.deepOrangeAccent;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      icon = Icons.description_rounded;
      color = Colors.indigo.shade600;
    } else {
      icon = Icons.insert_drive_file_rounded;
      color = Colors.grey.shade700;
    }

    return Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
