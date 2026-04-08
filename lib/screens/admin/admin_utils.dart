import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTheme {
  static const Color primary      = Color(0xFF0D9488);    // Teal 600
  static const Color primaryLight = Color(0xFFF0FDFA); // Teal 50
  static const Color slate900     = Color(0xFF0F172A);
  static const Color slate700     = Color(0xFF334155);
  static const Color slate500     = Color(0xFF64748B);
  static const Color slate200     = Color(0xFFE2E8F0);
  static const Color slate100     = Color(0xFFF1F5F9);
  static const Color slate50      = Color(0xFFF8FAFC);
}

class AdminUtils {
  static String timeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
