import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:right_case/view/client_screen_view/client_edit_screen.dart';

import 'package:right_case/view_model/client_view_model.dart';
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
    return Consumer<ClientViewModel>(
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
                          Text(client.mobileNumber.toString())
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
                          contactService.makePhoneCall(
                              context, client.mobileNumber);
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
                          contactService.sendSMS(context, client.mobileNumber);
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
                        onTap: () {
                          contactService.openWhatsApp(
                              context, client.mobileNumber);
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
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          content: Consumer<ClientViewModel>(
            builder: (context, clientViewModel, child) {
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          clientViewModel.removeClient(client);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
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
