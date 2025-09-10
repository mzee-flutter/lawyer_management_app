import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/services/login_and_signup_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: SingleChildScrollView(
            child: Consumer<LoginAndSignUpViewModel>(
              builder: (context, loginAndSignUpVM, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Center(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        'Enter your registered email address below to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    CustomTextField.fieldLabel('Enter Your Email'),
                    CustomTextField(
                        controller: loginAndSignUpVM.emailController),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () {
                          loginAndSignUpVM.resetPassword(context);
                          loginAndSignUpVM.emailController.clear();
                        },
                        child: loginAndSignUpVM.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Remember your password? ',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 14.sp),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
