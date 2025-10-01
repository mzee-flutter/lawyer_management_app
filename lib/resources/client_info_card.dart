import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/view/client_screen_view/client_edit_screen.dart';
import 'package:right_case/view_model/client_view_model/client_archive_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:right_case/view_model/services/contact_service.dart';

class ClientInfoCard extends StatelessWidget {
  ClientInfoCard({
    super.key,
    required this.client,
  });
  final ContactService contactService = ContactService();
  final ClientModel client;

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientListViewModel>(
      builder: (context, clientViewModel, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.r),
          child: Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 35.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          client.name.characters.first,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150.w,
                            child: Text(
                              client.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(client.phone.toString())
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          showDeleteClientDialog(context, client);
                        },
                        child: Container(
                          height: 30.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.r)),
                          child: Icon(
                            Icons.delete_rounded,
                            color: Colors.grey.shade800,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.r),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientEditScreen(client: client),
                            ),
                          );
                        },
                        child: Container(
                          height: 30.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.r)),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.grey.shade800,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact now',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 11.sp),
                          ),
                          Text(
                            'Call and Message',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          contactService.makePhoneCall(context, client.phone);
                        },
                        child: Container(
                          height: 25.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.phone_rounded,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {
                          contactService.sendSMS(context, client.phone);
                        },
                        child: Container(
                          height: 25.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.message_rounded,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () async {
                          contactService.openWhatsApp(context, client.phone);
                        },
                        child: Container(
                          height: 25.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            FontAwesomeIcons.whatsapp,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteClientDialog(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          content: Consumer<ClientArchiveViewModel>(
            builder: (context, clientArchiveVM, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Delete Client',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Are you sure you want to delete this client?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _deleteConformationButtons(
                        title: "Cancel",
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      _deleteConformationButtons(
                          title: "Archive",
                          color: Colors.orangeAccent,
                          onTap: () {
                            clientArchiveVM.archiveClient(context, client.id);
                            Navigator.of(context).pop();
                          }),
                      SizedBox(width: 10.w),
                      _deleteConformationButtons(
                        title: "Delete",
                        color: Colors.red,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

Widget _deleteConformationButtons({
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Container(
    height: 40,
    width: 75,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(50),
    ),
    child: InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

/// This code is for testing to launch the url
// await launchUrl(Uri.parse("https://flutter.dev"),
// mode: LaunchMode.externalApplication);
