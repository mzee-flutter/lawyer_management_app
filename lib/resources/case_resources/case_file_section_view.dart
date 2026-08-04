import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/case_all_files_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_files_service_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';
import 'package:right_case/view_model/cases_view_model/remove_case_file_view_model.dart';

import '../system_design/rc_theme.dart';

/// Compact summary row for case files. Lives as the first child inside a
/// bordered `RC.surface` card (see `_OtherInfoSection`), so it carries no
/// background/shadow/margin of its own.
class CaseFilesEmbeddedSection extends StatelessWidget {
  final List<CaseFileModel>? files;

  const CaseFilesEmbeddedSection({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    final totalFiles = files?.length ?? 0;
    final hasFiles = totalFiles > 0;

    return InkWell(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      onTap: !hasFiles ? null : () => _openAllFiles(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                  color: RC.goldLight,
                  borderRadius: BorderRadius.circular(8.r)),
              child:
                  Icon(Icons.folder_copy_outlined, color: RC.gold, size: 16.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Case Files', style: RC.label()),
                  SizedBox(height: 2.h),
                  Text(
                    hasFiles
                        ? '$totalFiles file${totalFiles == 1 ? '' : 's'} attached'
                        : 'No files uploaded yet',
                    style: RC.body(
                        color: hasFiles ? RC.textPrimary : RC.textTertiary),
                  ),
                ],
              ),
            ),
            if (hasFiles) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: RC.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('$totalFiles',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: RC.navy)),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_right_rounded,
                  size: 18.sp, color: RC.textTertiary),
            ],
          ],
        ),
      ),
    );
  }

  void _openAllFiles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
                value: context.read<CaseFilesViewModel>()),
            ChangeNotifierProvider.value(
                value: context.read<CaseFilesServiceViewModel>()),
            ChangeNotifierProvider.value(
                value: context.read<RemoveCaseFileViewModel>()),
          ],
          child: const CaseAllFilesScreenView(),
        ),
      ),
    );
  }
}
