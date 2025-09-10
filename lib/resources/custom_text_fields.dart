import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType = TextInputType.text;
  final int maxLines = 1;
  int? maxLength;
  List<TextInputFormatter>? inputFormatter;

  CustomTextField({
    super.key,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatter,
    required this.controller,
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
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatter,
        cursorColor: Colors.grey.shade800,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
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
