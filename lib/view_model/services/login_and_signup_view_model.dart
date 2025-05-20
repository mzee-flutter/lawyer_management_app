import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/utils/routes/routes_names.dart';

class LoginAndSignUpViewModel with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loginUser(context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty) {
      SnakeBars.flutterToast('Enter email', context);
    } else if (password.isEmpty) {
      SnakeBars.flutterToast('Enter Password', context);
    } else if (password.length <= 6) {
      SnakeBars.flutterToast('Password must be at least 6-character', context);
    }
    try {
      toggleLoading(true);
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// user.getIdToken() is used for the authenticating the user with they calling the API
      ///But for just login and register using user.uid is efficient because it is not expire usually
      String? userId = userCredential.user?.uid;

      if (userId != null) {
        final box = Hive.box('authBox');
        box.put('userId', userId);
        box.put('email', email);
        box.put('isLoggedIn', true);
        toggleLoading(false);
        clearFields();
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesName.homeScreen, (route) => false);
      }
    } catch (e) {
      if (kDebugMode) {
        toggleLoading(false);
        SnakeBars.flutterToast(e.toString(), context);
        print(e.toString());
      }
    }
  }

  Future<void> registerUser(context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty) {
      SnakeBars.flutterToast('Enter email', context);
    } else if (password.isEmpty) {
      SnakeBars.flutterToast('Enter Password', context);
    } else if (password.length <= 6) {
      SnakeBars.flutterToast('Password must be at least 6-character', context);
    }
    try {
      toggleLoading(true);
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? userId = userCredential.user?.uid;

      if (userId != null) {
        final box = Hive.box('authBox');
        box.put('userId', userId);
        box.put('email', email);
        box.put('isLoggedIn', true);
        toggleLoading(false);
        clearFields();
        Navigator.pushNamedAndRemoveUntil(
            context, RoutesName.homeScreen, (route) => false);
      }
    } catch (e) {
      if (kDebugMode) {
        toggleLoading(false);
        SnakeBars.flutterToast(e.toString(), context);
        print(e.toString());
      }
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  void resetPassword(context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      SnakeBars.flutterToast('please enter your email', context);
      return;
    }

    try {
      toggleLoading(true);
      await auth.sendPasswordResetEmail(email: email);
      toggleLoading(false);
      clearFields();
      SnakeBars.flutterToast('Password Reset Email is Sent', context);
    } catch (e) {
      toggleLoading(false);
      SnakeBars.flutterToast(e.toString(), context);
    }
  }

  Future<void> logOut() async {
    await auth.signOut();
    final box = Hive.box('authBox');
    await box.clear();
  }

  Future<void> checkLoginSession(BuildContext context) async {
    final box = Hive.box('authBox');
    final isLoggedIn = box.get('isLoggedIn', defaultValue: false);

    if (isLoggedIn) {
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.homeScreen, (route) => false);
    } else {
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.signInScreen, (route) => false);
    }
  }
}
