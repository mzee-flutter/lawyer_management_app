import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/view_model/client_view_model/client_restore_view_model.dart';

import '../system_design/rc_theme.dart';

class ArchivedClientInfoCard extends StatelessWidget {
  final ClientModel client;
  const ArchivedClientInfoCard({super.key, required this.client});

  // Fixed: client.name.characters.first threw on an empty name.
  String get _initial =>
      client.name.trim().isNotEmpty ? client.name.trim()[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: RC.divider, width: 1),
        boxShadow: [RC.cardShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gold strip = archived state, matches ArchivedCaseCard convention
            Container(width: 4.w, color: RC.gold),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 13.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: RC.navy,
                              borderRadius: BorderRadius.circular(10.r)),
                          child: Text(
                            _initial,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RC.body().copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5.sp),
                              ),
                              SizedBox(height: 3.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                    color: RC.goldLight,
                                    borderRadius: BorderRadius.circular(20.r)),
                                child: Text(
                                  'ARCHIVED',
                                  style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: RC.warningText,
                                      letterSpacing: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<ClientRestoreViewModel>(
                          builder: (_, vm, __) => _RestoreButton(
                            onTap: () => vm.handleRestore(context, client.id),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),
                    Divider(color: RC.divider, height: 1, thickness: 0.5),
                    SizedBox(height: 10.h),

                    // Structured info grid — replaces the old bold-label/value
                    // row list, which read as a raw data dump.
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _InfoChip(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: client.phone.toString()),
                        if (client.email.isNotEmpty)
                          _InfoChip(
                              icon: Icons.mail_outline_rounded,
                              label: 'Email',
                              value: client.email),
                        if (client.address.isNotEmpty)
                          _InfoChip(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: client.address),
                      ],
                    ),

                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 11.sp, color: RC.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          'Added ${DateFormat('dd MMM yyyy').format(client.createdAt)}',
                          style: RC
                              .caption(color: RC.textTertiary)
                              .copyWith(fontSize: 10.5.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RestoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: RC.navy, borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore_rounded, size: 12.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Restore',
                style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 220.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: RC.background, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: RC.textTertiary),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RC
                  .caption(color: RC.textSecondary)
                  .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
