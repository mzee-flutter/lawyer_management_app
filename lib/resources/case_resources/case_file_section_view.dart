import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CaseAllFilesScreenView extends StatelessWidget {
  final List<CaseFileModel>? files;

  const CaseAllFilesScreenView({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text(
          "Case Files",
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔹 Body Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCaseFilesSection(files, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseFilesSection(
      List<CaseFileModel>? files, BuildContext context) {
    if (files == null || files.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "No files uploaded yet.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      );
    }

    IconData getFileIcon(String filename) {
      final lower = filename.toLowerCase();
      if (lower.endsWith(".pdf")) return Icons.picture_as_pdf_rounded;
      if (lower.endsWith(".jpg") ||
          lower.endsWith(".jpeg") ||
          lower.endsWith(".png")) {
        return Icons.image_outlined;
      }
      if (lower.endsWith(".doc") || lower.endsWith(".docx")) {
        return Icons.description_outlined;
      }
      if (lower.endsWith(".xls") || lower.endsWith(".xlsx")) {
        return Icons.table_chart_outlined;
      }
      if (lower.endsWith(".txt")) return Icons.notes_outlined;
      return Icons.insert_drive_file_outlined;
    }

    void openFilePreview(CaseFileModel file) async {
      final filename = file.filename.toLowerCase();
      final url = file.fileUrl;

      if (filename.endsWith(".pdf")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(file.filename),
                backgroundColor: Colors.grey.shade300,
              ),
              body: PDFView(filePath: url),
            ),
          ),
        );
      } else if (filename.endsWith(".jpg") ||
          filename.endsWith(".jpeg") ||
          filename.endsWith(".png")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(file.filename),
                backgroundColor: Colors.grey.shade300,
              ),
              body: Center(
                child: InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        );
      } else {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: ListView.separated(
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final file = files[index];

          return Card(
            color: Colors.grey.shade300,
            elevation: 3,
            shadowColor: Colors.indigo.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.white,
                child: Icon(
                  getFileIcon(file.filename),
                  color: Colors.grey.shade900,
                  size: 26,
                ),
              ),
              title: Text(
                file.filename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Uploaded: ${DateFormat('dd MMM yyyy, hh:mm a').format(file.uploadedAt)}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.grey.shade900,
                ),
                onPressed: () => openFilePreview(file),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.folder_copy_outlined,
            color: Colors.grey.shade700,
            size: 22,
          ),
        ),
        title: const Text(
          "Case Related Files",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          totalFiles > 0 ? "files($totalFiles)" : "No files uploaded yet",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade900),
        onTap: totalFiles > 0
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CaseAllFilesScreenView(files: files),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
