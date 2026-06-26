import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';

import 'package:flutter/material.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';

class HearingCreateScreenView extends StatelessWidget {
  final String caseId;
  const HearingCreateScreenView({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    final hearingCreateVM = context.watch<HearingCreateViewModel>();
    final hearingListVM = context.read<HearingListViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Add Case Hearing",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 10.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabels("Select Next Hearing Date"),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              tileColor: Colors.grey.shade300,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              title: Text(
                hearingCreateVM.hearingDateTime == null
                    ? "Select Next Hearing Date"
                    : hearingCreateVM.hearingDateTime
                        .toString()
                        .split(" ")
                        .first,
              ),
              trailing: Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                hearingCreateVM.setHearingDateTime(date);
              },
            ),

            SizedBox(height: 12.h),

            _buildLabels('Enter Hearing Title'),
            _buildTextField(hearingCreateVM.hearingTitleController),
            SizedBox(height: 12.h),

            // Notes
            _buildLabels("Enter Case Notes"),
            _buildTextField(
              hearingCreateVM.hearingNotesController,
              maxLines: 3,
            ),
            Spacer(),

            ElevatedButton(
              onPressed: hearingCreateVM.loading
                  ? null
                  : () async {
                      try {
                        final dbHearing =
                            await hearingCreateVM.createHearing(caseId);
                        hearingListVM.addHearingLocally(dbHearing);

                        hearingCreateVM.resetFields();
                        Navigator.pop(context);
                        SnakeBars.flutterToast(
                          "Hearing added successfully",
                          context,
                        );
                      } catch (e) {
                        SnakeBars.flutterToast(
                          e.toString(),
                          context,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: hearingCreateVM.loading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_calendar, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Hearing',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: Colors.grey.shade800,
      maxLength: maxLength,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLabels(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
    );
  }
}
