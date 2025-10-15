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
    final formattedDate =
        DateFormat('dd MMM, yyyy').format(caseData.registrationDate);
    final caseStatus =
        caseData.caseStatus?.name ?? caseData.status ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        centerTitle: true,
        title: const Text("Case Preview",
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.indigo.shade900,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
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
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 14.h),

            /// Quick Actions Card (Add Fees, Hearing, Client)
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _action(Icons.account_balance_wallet_outlined, "Add Fees"),
                  _action(Icons.event_available_outlined, "Add Hearing"),
                  _action(Icons.person_add_alt_1_outlined, "Add Client"),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            /// Case Status Section
            _sectionTitle("Change Case Status"),
            Text("Click and move Pending → Active → DisposedOf",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statusStep("Pending", caseStatus.toLowerCase() == "pending"),
                _statusLine(),
                _statusStep("Active", caseStatus.toLowerCase() == "active"),
                _statusLine(),
                _statusStep(
                    "DisposedOf", caseStatus.toLowerCase() == "disposedof"),
              ],
            ),

            SizedBox(height: 24.h),

            /// Case Basic Info
            _sectionHeader("Case Basic Information", trailing: "Sticky Notes"),
            _infoTile(
                Icons.calendar_today_outlined, "Register Date: $formattedDate"),
            _infoTile(Icons.confirmation_number_outlined,
                "Case Number: ${caseData.caseNumber}"),
            _infoTile(Icons.category_outlined,
                "Case Type: ${caseData.caseType?.name ?? 'Not Added'}"),
            _infoTile(Icons.layers_outlined,
                "Case Stage: ${caseData.caseStage?.name ?? 'Not Added'}"),
            _infoTile(Icons.flag_outlined,
                "Case Status: ${caseData.caseStatus?.name ?? 'Not Added'}"),
            _infoTile(Icons.price_change_outlined,
                "Legal Fees: ${caseData.legalFees?.toStringAsFixed(0) ?? 'N/A'}"),

            SizedBox(height: 18.h),

            _dropdownTile(
                "Case Study", caseData.caseNotes ?? "No notes added."),

            SizedBox(height: 22.h),

            _sectionTitle("Court Information"),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _courtCard(Icons.house_outlined, "Court Category",
                    caseData.courtCategory?.name ?? "N/A"),
                _courtCard(Icons.account_balance_outlined, "Court Name",
                    caseData.courtName ?? "N/A"),
                _courtCard(
                    Icons.person_outline, "Judge", caseData.judgeName ?? "N/A"),
              ],
            ),

            SizedBox(height: 24.h),

            /// Other Info
            _sectionTitle("Other Information"),
            _iconInfo(Icons.insert_drive_file_outlined, "Related Files",
                "${caseData.relatedFiles?.length ?? 0} file(s)"),
            _iconInfo(Icons.calendar_month_outlined, "Created At",
                DateFormat('dd MMM, yyyy').format(caseData.createdAt)),
            if (caseData.updatedAt != null)
              _iconInfo(Icons.update, "Last Updated",
                  DateFormat('dd MMM, yyyy').format(caseData.updatedAt!)),

            SizedBox(height: 80.h),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade900,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EditCaseScreen(clientCase: caseData)),
          );
        },
        icon: Icon(Icons.edit_outlined, color: Colors.grey.shade300),
        label: Text("Edit Case", style: TextStyle(color: Colors.grey.shade300)),
      ),
    );
  }

  // ---------- Reusable UI Components ----------

  Widget _action(IconData icon, String label) => Column(
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

  Widget _statusStep(String label, bool active) => Column(
        children: [
          Icon(Icons.check_circle,
              color: active ? Colors.redAccent : Colors.grey, size: 22.sp),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _statusLine() =>
      Container(height: 2.h, width: 30.w, color: Colors.redAccent);

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
