import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_update_view_model.dart';

import '../../resources/client_resources/rc_form_field.dart';
import '../../resources/custom_text_fields.dart';
import '../../resources/system_design/rc_theme.dart';

class ClientEditScreen extends StatefulWidget {
  final ClientModel client;
  const ClientEditScreen({super.key, required this.client});
  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fixed: the old `late editViewModel` field was shadowed by Consumer's
    // identically-named builder parameter and never actually used.
    context.read<ClientUpdateViewModel>().initializeFields(widget.client);
  }

  Future<void> _submit(ClientUpdateViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await vm.saveChanges(context, widget.client.id);
      if (!mounted) return;
      context.read<ClientListViewModel>().unFocusSearch();
      Navigator.pop(context); // Fixed: screen used to just sit there after save
      SnakeBars.flutterToast('Client updated successfully', context);
    } catch (_) {
      if (!mounted) return;
      SnakeBars.flutterToast('Failed to update client', context);
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
            Text('Edit Client',
                style: TextStyle(
                    color: RC.textOnDark,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700)),
            Text(widget.client.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: RC.textOnDarkMuted, fontSize: 12.sp)),
          ],
        ),
      ),
      body: Consumer<ClientUpdateViewModel>(
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
                    // CNIC unified to optional — was inconsistently required
                    // here but optional on AddClientScreen for the same entity.
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
                      controller: vm.phoneController,
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
                              Icon(Icons.save_outlined,
                                  color: Colors.white, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text('Save Changes',
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
