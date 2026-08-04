// Shared RC-themed form primitives for non-auth data-entry screens
// (clients today; reusable for any future form). Kept separate from
// AuthTextField since login/signup have distinct focus/obscure behaviour.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../system_design/rc_theme.dart';

class RCFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const RCFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: RC.label().copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: RC.textSecondary),
            children: required
                ? [TextSpan(text: ' *', style: TextStyle(color: RC.danger))]
                : null,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(fontSize: 13.5.sp, color: RC.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: RC.textTertiary, fontSize: 13.sp),
            prefixIcon: Icon(icon, size: 18.sp, color: RC.textSecondary),
            filled: true,
            fillColor: RC.background,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: RC.divider, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: RC.divider, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: RC.navy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: RC.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: RC.danger, width: 1.5),
            ),
            errorStyle: TextStyle(color: RC.danger, fontSize: 11.sp),
          ),
        ),
      ],
    );
  }
}

/// Titled, elevated field group — same visual language as the
/// Court Portal / Task Board section headers.
class RCFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const RCFormSection(
      {super.key,
      required this.title,
      required this.icon,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [RC.cardShadow]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: RC.navy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r)),
              border: Border(bottom: BorderSide(color: RC.divider, width: 0.5)),
            ),
            child: Row(children: [
              Icon(icon, size: 16.sp, color: RC.navy),
              SizedBox(width: 8.w),
              Text(title,
                  style: RC
                      .body(color: RC.navy)
                      .copyWith(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) SizedBox(height: 14.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
