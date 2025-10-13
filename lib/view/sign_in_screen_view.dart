import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/resources/login_icons.dart';

import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/login_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Consumer<LoginViewModel>(
                  builder: (context, loginVM, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // for horizontal
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            color: Color(0xFF0077B5),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Login to your existing account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.h),

                        // Email
                        CustomTextField.fieldLabel(
                            'Enter your email, phone, or username'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: loginVM.emailController,
                        ),
                        SizedBox(height: 15.h),

                        // Password
                        CustomTextField.fieldLabel('Enter your password'),
                        SizedBox(height: 5.h),
                        CustomTextField(
                          controller: loginVM.passwordController,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RoutesName.forgotPasswordScreen);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF0077B5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Login button
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: () async {
                            final valid = await loginVM.loginUser(context);
                            if (valid) {
                              Navigator.pushReplacementNamed(
                                  context, RoutesName.homeScreen);
                            } else {
                              debugPrint('Login Failed');
                            }
                            loginVM.clearFields();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: loginVM.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        // OR divider
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[400], thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                'Or login with',
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey[400], thickness: 1)),
                          ],
                        ),

                        // Social icons
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

                        // Sign Up Link
                        SizedBox(height: 30.h),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RoutesName.signUpScreen);
                          },
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account yet? ",
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[600]),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
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
