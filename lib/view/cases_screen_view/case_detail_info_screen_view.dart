import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view/cases_screen_view/case_edit_screen.dart';

class CaseDetailInfoScreenView extends StatelessWidget {
  final CaseModel caseData;

  const CaseDetailInfoScreenView({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Main Body
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Case Overview"),
            _infoCard([
              _infoRow("Case Number", caseData.caseNumber),
              _infoRow("Status", caseData.status ?? "N/A"),
              _infoRow("Registered On",
                  dateFormat.format(caseData.registrationDate)),
            ]),
            _buildSectionTitle("Court Information"),
            _infoCard([
              _infoRow("Court", caseData.courtName ?? "N/A"),
              _infoRow("Judge", caseData.judgeName ?? "N/A"),
              _infoRow("Category", caseData.courtCategory?.name ?? "N/A"),
              _infoRow("Case Type", caseData.caseType?.name ?? "N/A"),
              _infoRow("Stage", caseData.caseStage?.name ?? "N/A"),
            ]),
            _buildSectionTitle("Parties"),
            _infoCard([
              _infoRow("First Party ID", caseData.firstPartyId),
              _infoRow("Second Party ID", caseData.secondPartyId),
              _infoRow("Opposite Party", caseData.oppositePartyName ?? "N/A"),
            ]),
            _buildSectionTitle("Case Details"),
            _infoCard([
              _infoRow(
                  "Legal Fees",
                  caseData.legalFees != null
                      ? "PKR ${caseData.legalFees!.toStringAsFixed(0)}"
                      : "N/A"),
              _multiLineInfo(
                  "Notes", caseData.caseNotes ?? "No notes available."),
            ]),
            if (caseData.files != null && caseData.files!.isNotEmpty) ...[
              _buildSectionTitle("Attached Files"),
              _fileList(caseData.files!),
            ],
            SizedBox(height: 80.h),
          ],
        ),
      ),

      // Floating Bottom Actions
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit Case"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCaseScreen(clientCase: caseData),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text("Delete"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  _showDeleteDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 🔹 Info Card Wrapper
  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // 🔹 Key-Value Row
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Multi-line info (for notes)
  Widget _multiLineInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 File List
  Widget _fileList(List files) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: files.map((file) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: Text(
              file.fileName ?? "Untitled File",
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: Icon(Icons.download_outlined, color: Colors.blueAccent),
            onTap: () {
              // handle file open/download
            },
          );
        }).toList(),
      ),
    );
  }

  // 🔹 Delete Dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Case"),
        content: const Text("Are you sure you want to delete this case?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // delete logic
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
