import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginIcons extends StatelessWidget {
  final String assetPath;
  const LoginIcons({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
