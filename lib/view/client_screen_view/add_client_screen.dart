import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_create_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

import '../../resources/client_resources/rc_form_field.dart';
import '../../resources/custom_text_fields.dart';
import '../../resources/system_design/rc_theme.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});
  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit(ClientCreateViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await vm.submitClient(context);
      if (!mounted) return;
      vm.clearFields();
      context.read<ClientListViewModel>().unFocusSearch();
      Navigator.pop(
          context); // Fixed: screen used to just sit there after submit
      SnakeBars.flutterToast('Client added successfully', context);
    } catch (_) {
      if (!mounted) return;
      SnakeBars.flutterToast('Failed to add client', context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Add Client',
                style: TextStyle(
                    color: RC.textOnDark,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700)),
            Text('Create a new client record',
                style: TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp)),
          ],
        ),
      ),
      body: Consumer<ClientCreateViewModel>(
        builder: (context, vm, __) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                RCFormSection(
                  title: 'Client Identity',
                  icon: Icons.badge_outlined,
                  children: [
                    RCFormField(
                      controller: vm.nameController,
                      label: 'Full name',
                      hint: 'e.g. Ahmed Khan',
                      icon: Icons.person_outline_rounded,
                      required: true,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    RCFormField(
                      controller: vm.cnicController,
                      label: 'CNIC',
                      hint: '00000-0000000-0',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                RCFormSection(
                  title: 'Contact Information',
                  icon: Icons.contact_phone_outlined,
                  children: [
                    RCFormField(
                      controller: vm.emailController,
                      label: 'Email address',
                      hint: 'client@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    RCFormField(
                      controller: vm.mobileController,
                      label: 'Mobile number',
                      hint: '03XX XXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                        SpaceAfterFourDigitsFormatter(),
                      ],
                    ),
                    RCFormField(
                      controller: vm.addressController,
                      label: 'Address',
                      hint: 'Street, city',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
                RCFormSection(
                  title: 'Additional Notes',
                  icon: Icons.notes_outlined,
                  children: [
                    RCFormField(
                      controller: vm.notesController,
                      label: 'Notes',
                      hint: 'Anything worth remembering about this client…',
                      icon: Icons.sticky_note_2_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _submit(vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RC.navy,
                      disabledBackgroundColor: RC.navy.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: vm.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded,
                                  color: Colors.white, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text('Add Client',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
