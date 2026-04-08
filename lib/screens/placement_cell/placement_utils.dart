import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlacementTheme {
  static const Color primary      = Color(0xFF9333EA);
  static const Color primaryLight = Color(0xFFFAF5FF);
  static const Color slate900     = Color(0xFF0F172A);
  static const Color slate700     = Color(0xFF334155);
  static const Color slate500     = Color(0xFF64748B);
  static const Color slate200     = Color(0xFFE2E8F0);
  static const Color slate100     = Color(0xFFF1F5F9);
  static const Color slate50      = Color(0xFFF8FAFC);
}

class PlacementUtils {
  static const List<String> statusOptions = [
    'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected',
  ];

  static Color statusColor(String s) {
    switch (s) {
      case 'Shortlisted': return const Color(0xFF10B981);
      case 'Interview':   return const Color(0xFF4F46E5);
      case 'Offer':       return const Color(0xFFF59E0B);
      case 'Rejected':    return const Color(0xFFEF4444);
      default:            return const Color(0xFF3B82F6);
    }
  }

  static String fmt(dynamic ts) {
    if (ts == null) return '—';
    try {
      return DateFormat('MMM d, yyyy').format((ts as Timestamp).toDate());
    } catch (_) {
      return '—';
    }
  }

  static Future<void> updateStatus(String docId, String newStatus) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('applications').doc(docId).get();
    if (!docSnapshot.exists) return;
    final data = docSnapshot.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection('applications')
        .doc(docId)
        .update({'status': newStatus});

    if (newStatus == 'Shortlisted' || newStatus == 'Offer' || newStatus == 'Rejected') {
      String title = '';
      String message = '';
      if (newStatus == 'Shortlisted') {
        title = 'Application Shortlisted';
        message = 'Congratulations! You have been shortlisted for ${data['jobTitle']} at ${data['company']}.';
      } else if (newStatus == 'Offer') {
        title = 'Offer Received';
        message = 'Congratulations! You have received an offer for ${data['jobTitle']} at ${data['company']}.';
      } else if (newStatus == 'Rejected') {
        title = 'Application Update';
        message = 'Unfortunately, your application for ${data['jobTitle']} at ${data['company']} was not moved forward.';
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'type': 'status',
        'targetUserId': data['studentId'],
        'createdAt': FieldValue.serverTimestamp(),
        'isNew': true,
      });
    }
  }
}
