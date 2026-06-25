import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/case_all_files_screen_view.dart';
import 'package:right_case/view_model/cases_view_model/case_files_service_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_files_view_model.dart';
import 'package:right_case/view_model/cases_view_model/remove_case_file_view_model.dart';

class CaseFilesEmbeddedSection extends StatelessWidget {
  final List<CaseFileModel>? files;

  const CaseFilesEmbeddedSection({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    final totalFiles = files?.length ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.folder_copy_outlined),
        title: const Text("Case Related Files"),
        subtitle: Text(
          totalFiles > 0 ? "files($totalFiles)" : "No files uploaded yet",
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: totalFiles == 0
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(
                          value: context.read<CaseFilesViewModel>(),
                        ),
                        ChangeNotifierProvider.value(
                          value: context.read<CaseFilesServiceViewModel>(),
                        ),
                        ChangeNotifierProvider.value(
                          value: context.read<RemoveCaseFileViewModel>(),
                        ),
                      ],
                      child: const CaseAllFilesScreenView(),
                    ),
                  ),
                );
              },
      ),
    );
  }
}
