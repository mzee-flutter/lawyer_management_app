import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/login_user_info_view_model.dart';
import 'package:right_case/view_model/auth_view_models/logout_view_model.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({
    super.key,
  });

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
            child: Consumer2<RegisterViewModel, LoginUserInfoViewModel>(
              builder: (BuildContext context, registerVM, loginUserInfoMV,
                  Widget? child) {
                final user = registerVM.user;
                final loginUserInfo = loginUserInfoMV.loggedInUserInfo;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade800,
                      child: Text(
                          user?.name.characters.first ??
                              loginUserInfo?.name.characters.first ??
                              'X',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user?.name ?? loginUserInfo?.name ?? "Unknown",
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp),
                    ),
                    Text(
                      user?.email ?? loginUserInfo?.email ?? "example.com",
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                );
              },
            ),
          ),

          Consumer<ClientArchivedListViewModel>(
            builder:
                (BuildContext context, clientArchivedListVM, Widget? child) {
              return ListTile(
                leading: Icon(Icons.archive_rounded, color: Colors.blue),
                title: Text("Archived Clients"),
                subtitle: Text("Restore it from here..."),
                onTap: () async {
                  Navigator.pushNamed(
                      context, RoutesName.archivedClientsScreen);
                },
              );
            },
          ),

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
          Consumer<LogoutViewModel>(
            builder: (BuildContext context, logoutVM, Widget? child) {
              return AboutAppIcons(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () async {
                  await logoutVM.logoutUser(context);
                },
              );
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
