import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactService {
  void makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      _showSnackBar(context, 'Phone number not available');
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(context, 'Could not launch phone dialer');
    }
  }

  void sendSMS(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      _showSnackBar(context, 'Phone number not available');
      return;
    }

    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(context, 'Could not launch messaging app');
    }
  }

  void openWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      _showSnackBar(context, 'Phone number not available');
      return;
    }

    // Format: https://wa.me/<number> or https://api.whatsapp.com/send?phone=<number>
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar(context, 'Could not launch WhatsApp');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// checking that contact works or not just running the code...
