import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/resources/login_icons.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.r),
                child: Consumer<RegisterViewModel>(
                  builder: (context, registerVM, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'RightCase',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0077B5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Create a Lawyer Account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.h),

                        // First Name
                        CustomTextField.fieldLabel('Your first name'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: TextEditingController(),
                        ),
                        SizedBox(height: 15.h),

                        // Last Name
                        CustomTextField.fieldLabel('Your last name'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: registerVM.nameController,
                        ),
                        SizedBox(height: 15.h),
                        // Email
                        CustomTextField.fieldLabel('Enter your email'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: registerVM.emailController,
                        ),
                        SizedBox(height: 15.h),
                        // Password
                        CustomTextField.fieldLabel('Enter your password'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: registerVM.passwordController,
                        ),

                        SizedBox(height: 20.h),

                        ElevatedButton(
                          onPressed: () async {
                            final user = await registerVM.registerUser(context);
                            if (user != null) {
                              Navigator.pushReplacementNamed(
                                  context, RoutesName.homeScreen);
                            }
                            registerVM.clearFields();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: registerVM.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Create new account',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        SizedBox(height: 15.h),

                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[400], thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                'Or signup with',
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[400], thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoginIcons(assetPath: 'images/google1.png'),
                            SizedBox(width: 20.w),
                            LoginIcons(assetPath: 'images/facebook.png'),
                            SizedBox(width: 20.w),
                            LoginIcons(assetPath: 'images/apple.png'),
                          ],
                        ),
                        SizedBox(height: 30.h),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesName.signInScreen);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  TextSpan(
                                    text: 'SignIn',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF0077B5),
                                      fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
