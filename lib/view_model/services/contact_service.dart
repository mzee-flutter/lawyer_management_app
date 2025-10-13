import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactService {
  String formatNumber(String rawNumber) {
    String digits = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    }
    return digits;
  }

  void makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      _showSnackBar(context, 'Phone number not available');
      return;
    }

    final cleanNumber = formatNumber(phoneNumber);
    final formatted =
        cleanNumber.startsWith('+') ? cleanNumber : '+$cleanNumber';

    final Uri phoneUri = Uri(scheme: 'tel', path: formatted);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
    } else {
      _showSnackBar(context, 'Could not launch phone dialer');
    }
  }

  void sendSMS(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      _showSnackBar(context, 'Phone number not available');
      return;
    }

    final cleanNumber = formatNumber(phoneNumber);
    final Uri smsUri = Uri(scheme: 'sms', path: cleanNumber);

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

    final cleanNumber = formatNumber(phoneNumber);
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanNumber");

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
