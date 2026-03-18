import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color accentTeal = Color(0xFF0EA5E9);
  static const Color secondary = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color rejected = Color(0xFFEC4899);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color gradientStart = Color(0xFF2563EB);
  static const Color gradientEnd = Color(0xFF0EA5E9);

  static Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return warning;
      case 'In Progress':
        return primary;
      case 'Resolved':
        return secondary;
      case 'Rejected':
        return error;
      default:
        return textSecondary;
    }
  }
}

class AppStrings {
  static const String appName = 'FixFlow';
  static const String tagline = 'Streamline. Report. Resolve.';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String submitComplaint = 'Submit Complaint';
  static const String myComplaints = 'My Complaints';
  static const String profile = 'Profile';
  static const String adminDashboard = 'Admin Dashboard';
  static const String about = 'About FixFlow';
  static const String noComplaints = 'No complaints submitted yet';
  static const String complaintSubmitted = 'Complaint submitted successfully!';
  static const String complaintDeleted = 'Complaint deleted successfully!';
  static const String complaintUpdated = 'Complaint updated successfully!';
  static const String signOutConfirm = 'Are you sure you want to sign out?';
  static const String deleteConfirm = 'Are you sure you want to delete this complaint?';
}

class AppCategories {
  static const List<String> categories = [
    'Electrical',
    'Plumbing',
    'Internet',
    'Maintenance',
    'Cleanliness',
    'Other',
  ];

  static Color categoryColor(String category) {
    switch (category) {
      case 'Electrical':
        return Colors.yellow.shade700;
      case 'Plumbing':
        return Colors.blue;
      case 'Internet':
        return Colors.purple;
      case 'Maintenance':
        return Colors.orange;
      case 'Cleanliness':
        return Colors.green;
      case 'Other':
      default:
        return Colors.grey;
    }
  }
}

class AppStatuses {
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String rejected = 'Rejected';

  static const List<String> statuses = [
    pending,
    inProgress,
    resolved,
    rejected,
  ];

  static const List<String> filterStatuses = [
    'All',
    pending,
    inProgress,
    resolved,
    rejected,
  ];
}

class CloudinaryConfig {
  static const String cloudName = 'dvsokdwsb';
  static const String uploadPreset = 'fixflow_images';
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
