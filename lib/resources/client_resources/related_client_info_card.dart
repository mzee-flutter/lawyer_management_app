import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/view_model/services/contact_service.dart';

class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F5F1);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );
}

class RelatedClientInfoCard extends StatelessWidget {
  final bool isSynced;
  final ClientModel client;
  final VoidCallback onRemoveFromCase;

  RelatedClientInfoCard({
    super.key,
    required this.isSynced,
    required this.client,
    required this.onRemoveFromCase,
  });

  final ContactService _contact = ContactService();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSynced ? 1.0 : 0.65,
      child: Container(
        decoration: BoxDecoration(
          color: _RC.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [_RC.card],
        ),
        child: Column(
          children: [
            // ── Header row ─────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
              child: Row(
                children: [
                  // Navy avatar with initial
                  Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _RC.navy,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      client.name.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Name + phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _RC.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          client.phone.toString(),
                          style: TextStyle(
                              fontSize: 12.sp, color: _RC.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Sync indicator or delete button
                  if (!isSynced)
                    Icon(Icons.schedule,
                        size: 18.sp, color: Colors.orange.shade700)
                  else
                    InkWell(
                      onTap: () => _confirmRemove(context),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: _RC.dangerSurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.person_remove_outlined,
                            size: 16.sp, color: _RC.danger),
                      ),
                    ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Divider(color: _RC.divider, height: 1, thickness: 0.5),
            ),

            // ── Contact actions ────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact now',
                        style:
                            TextStyle(fontSize: 11.sp, color: _RC.textTertiary),
                      ),
                      Text(
                        'Call & Message',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _RC.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _ContactBtn(
                    icon: Icons.phone_rounded,
                    onTap: () => _contact.makePhoneCall(context, client.phone),
                  ),
                  SizedBox(width: 8.w),
                  _ContactBtn(
                    icon: Icons.message_rounded,
                    onTap: () => _contact.sendSMS(context, client.phone),
                  ),
                  SizedBox(width: 8.w),
                  _ContactBtn(
                    icon: FontAwesomeIcons.whatsapp,
                    onTap: () => _contact.openWhatsApp(context, client.phone),
                    isWhatsApp: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: const Text('Remove client?'),
        content: const Text(
            'This only removes the client from this case, not from the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _RC.danger),
            onPressed: () {
              Navigator.pop(context);
              onRemoveFromCase();
            },
            child: const Text('Remove'),
          ),
        ],
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
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: isWhatsApp
              ? const Color(0xFF25D366).withValues(alpha: 0.12)
              : const Color(0xFF1A2744).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: isWhatsApp ? const Color(0xFF25D366) : const Color(0xFF1A2744),
        ),
      ),
    );
  }
}
