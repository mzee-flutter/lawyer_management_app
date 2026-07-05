import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/view/client_screen_view/client_edit_screen.dart';
import 'package:right_case/view_model/client_view_model/client_archive_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_permanent_delete_view_model.dart';
import 'package:right_case/view_model/services/contact_service.dart';

import '../system_design/rc_theme.dart';

class ClientInfoCard extends StatelessWidget {
  final ClientModel client;
  final ContactService _contact = ContactService();

  ClientInfoCard({super.key, required this.client});

  // Fixed: client.name.characters.first threw on an empty name. Guard it.
  String get _initial =>
      client.name.trim().isNotEmpty ? client.name.trim()[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    // No longer wrapped in a dead Consumer — this card never read the VM
    // it was subscribed to, so every list change rebuilt every card for
    // no reason. It's a pure StatelessWidget now.
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: RC.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: RC.divider, width: 1),
        boxShadow: [RC.cardShadow],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: RC.navy,
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Text(_initial,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RC.body().copyWith(
                              fontWeight: FontWeight.w700, fontSize: 14.sp)),
                      SizedBox(height: 3.h),
                      Row(children: [
                        Icon(Icons.phone_outlined,
                            size: 11.sp, color: RC.textTertiary),
                        SizedBox(width: 4.w),
                        Text(client.phone.toString(),
                            style: RC.caption(color: RC.textSecondary)),
                      ]),
                    ],
                  ),
                ),
                _IconAction(
                  icon: Icons.edit_outlined,
                  color: RC.gold,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ClientEditScreen(client: client)),
                  ),
                ),
                SizedBox(width: 6.w),
                _IconAction(
                  icon: Icons.delete_outline_rounded,
                  color: RC.danger,
                  onTap: () =>
                      showDeleteClientSheet(context: context, client: client),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: RC.divider, height: 1, thickness: 0.5),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Text('Quick contact',
                      style: RC
                          .caption(color: RC.textTertiary)
                          .copyWith(fontSize: 11.sp)),
                ),
                _ContactBtn(
                    icon: Icons.phone_rounded,
                    onTap: () => _contact.makePhoneCall(context, client.phone)),
                SizedBox(width: 8.w),
                _ContactBtn(
                    icon: Icons.message_rounded,
                    onTap: () => _contact.sendSMS(context, client.phone)),
                SizedBox(width: 8.w),
                _ContactBtn(
                  icon: FontAwesomeIcons.whatsapp,
                  onTap: () => _contact.openWhatsApp(context, client.phone),
                  isWhatsApp: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, size: 15.sp, color: color),
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isWhatsApp;
  const _ContactBtn(
      {required this.icon, required this.onTap, this.isWhatsApp = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: isWhatsApp
              ? const Color(0xFF25D366).withValues(alpha: 0.12)
              : RC.navy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon,
            size: 15.sp, color: isWhatsApp ? const Color(0xFF25D366) : RC.navy),
      ),
    );
  }
}

// ── Delete/Archive sheet — same pattern as CasesListScreen's _DeleteCaseSheet ──
void showDeleteClientSheet(
    {required BuildContext context, required ClientModel client}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: context.read<ClientArchiveViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<ClientPermanentDeleteViewModel>()),
        ChangeNotifierProvider.value(
            value: context.read<ClientListViewModel>()),
      ],
      child: _DeleteClientSheet(client: client),
    ),
  );
}

class _DeleteClientSheet extends StatelessWidget {
  final ClientModel client;
  const _DeleteClientSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
                width: 36.w,
                height: 4,
                decoration: BoxDecoration(
                    color: RC.divider, borderRadius: BorderRadius.circular(2))),
          ),
          SizedBox(height: 16.h),
          Container(
            width: 52.w,
            height: 52.w,
            decoration:
                BoxDecoration(color: RC.dangerSurface, shape: BoxShape.circle),
            child: Icon(Icons.person_remove_outlined,
                size: 24.sp, color: RC.danger),
          ),
          SizedBox(height: 12.h),
          Text('Remove client?',
              style: RC
                  .body()
                  .copyWith(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 5.h),
          Text(client.name,
              style: RC
                  .caption(color: RC.textSecondary)
                  .copyWith(fontSize: 12.5.sp)),
          SizedBox(height: 20.h),
          Consumer<ClientArchiveViewModel>(
            builder: (_, vm, __) => _SheetOption(
              icon: Icons.archive_outlined,
              label: 'Archive',
              subtitle: 'Hide from active list. Restorable later.',
              color: RC.warningText,
              surface: RC.warningSurface,
              border: RC.warningBorder,
              onTap: () async {
                await vm.archiveClient(context, client.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.read<ClientListViewModel>().unFocusSearch();
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          Consumer<ClientPermanentDeleteViewModel>(
            builder: (_, vm, __) => _SheetOption(
              icon: Icons.delete_forever_outlined,
              label: 'Delete permanently',
              subtitle: 'This cannot be undone.',
              color: RC.danger,
              surface: RC.dangerSurface,
              border: RC.dangerBorder,
              onTap: () async {
                await vm.deleteClientPermanent(context, client.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: RC
                      .body(color: RC.textSecondary)
                      .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: border, width: 0.8)),
        child: Row(children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 17.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: RC.body(color: color).copyWith(
                        fontSize: 13.sp, fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: RC
                        .caption(color: color.withValues(alpha: 0.85))
                        .copyWith(fontSize: 10.5.sp)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: color),
        ]),
      ),
    );
  }
}
