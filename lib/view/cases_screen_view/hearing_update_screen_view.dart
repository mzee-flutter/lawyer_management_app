import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_update_view_model.dart';

class HearingUpdateScreenView extends StatefulWidget {
  final HearingPublicModel hearingData;

  const HearingUpdateScreenView({
    super.key,
    required this.hearingData,
  });

  @override
  State<HearingUpdateScreenView> createState() =>
      HearingUpdateScreenViewState();
}

class HearingUpdateScreenViewState extends State<HearingUpdateScreenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hearingUpdateVM = context.read<HearingUpdateViewModel>();
      hearingUpdateVM.resetFields();
      hearingUpdateVM.initializeHearingField(widget.hearingData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hearingUpdateVM = context.watch<HearingUpdateViewModel>();
    final hearingListVM = context.read<HearingListViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Update Hearing",
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
                hearingUpdateVM.hearingDateTime == null
                    ? "Select Next Hearing Date"
                    : hearingUpdateVM.hearingDateTime
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
                if (date != null) {
                  hearingUpdateVM.setHearingDateTime(date);
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildLabels('Enter Hearing Title'),
            _buildTextField(hearingUpdateVM.hearingTitleController),
            SizedBox(height: 12.h),
            _buildLabels('Hearing Status '),
            DropdownButtonFormField<String>(
              value: hearingUpdateVM.hearingStatusController.text.isEmpty
                  ? null
                  : hearingUpdateVM.hearingStatusController.text,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              items: hearingUpdateVM.statuses
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  hearingUpdateVM.hearingStatusController.text = value;
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildLabels("Enter Case Notes"),
            _buildTextField(
              hearingUpdateVM.hearingNotesController,
              maxLines: 3,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: hearingUpdateVM.isLoading
                  ? null
                  : () async {
                      try {
                        final dbHearing = await hearingUpdateVM.updateHearing(
                          widget.hearingData.id,
                        );
                        hearingListVM.updateHearing(dbHearing);

                        hearingUpdateVM.resetFields();
                        Navigator.pop(context);
                        SnakeBars.flutterToast(
                          "Hearing updated successfully",
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
              child: hearingUpdateVM.isLoading
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
                          'Save Hearing',
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
