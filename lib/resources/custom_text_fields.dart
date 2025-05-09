import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String hint;

  const CustomTextField({
    super.key,
    required this.hint,
  });

  static Widget fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.h,
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        ),
      ),
    );
  }
}



class SpaceAfterFourDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    if (digitsOnly.length <= 4) {
      formatted = digitsOnly;
    } else {
      formatted = '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
