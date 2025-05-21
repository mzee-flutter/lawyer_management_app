import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/services/login_and_signup_view_model.dart';

class DrawerView extends StatelessWidget {
  DrawerView({
    super.key,
  });

  final LoginAndSignUpViewModel _loginAndSignUpViewModel =
      LoginAndSignUpViewModel();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade800,
                  child: Text("M",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                SizedBox(height: 8),
                Text(
                  "Muhammad",
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp),
                ),
                Text(
                  "isprofessorkhan@gmail.com",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),
          ),

          // Contact on WhatsApp
          ListTile(
            leading: Icon(Icons.chat, color: Colors.blue),
            title: Text("Contact on WhatsApp"),
            subtitle: Text("Contact our team via whatsapp"),
            onTap: () {},
          ),

          // About Us
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.orange),
            title: Text("About Us"),
            subtitle: Text("Information related to development"),
            onTap: () {},
          ),

          // Contact Us
          ListTile(
            leading: Icon(Icons.contact_phone, color: Colors.red),
            title: Text("Contact Us"),
            subtitle: Text("Anyone wants to contact our team"),
            onTap: () {},
          ),

          Divider(),

          // Share App
          AboutAppIcons(
            icon: Icons.share,
            title: 'Share App',
            onTap: () {},
          ),
          AboutAppIcons(
            icon: Icons.star_half,
            title: 'Rate App',
            onTap: () {},
          ),
          AboutAppIcons(
            icon: Icons.apps,
            title: 'More App',
            onTap: () {},
          ),
          AboutAppIcons(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          AboutAppIcons(
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () {
              _loginAndSignUpViewModel.logOut();
              Navigator.pushNamed(context, RoutesName.signInScreen);
            },
          ),
          AboutAppIcons(
            icon: Icons.delete_rounded,
            title: 'Delete Account',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class AboutAppIcons extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const AboutAppIcons({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }
}
