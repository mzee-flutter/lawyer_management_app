import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view_model/services/login_and_signup_view_model.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  SplashScreenViewState createState() => SplashScreenViewState();
}

class SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    final loginAndSignUpVM =
        Provider.of<LoginAndSignUpViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginAndSignUpVM.checkLoginSession(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey.shade300,
          child: Text('LOGO OF THE APP '),
        ),
      ),
    );
  }
}
