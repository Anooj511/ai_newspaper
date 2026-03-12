import 'package:intl/intl.dart';

class DateHelper {
  // Formats date like: Thursday, March 12, 2026
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  // Formats date like: Mar 12, 2026
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  // Formats time like: 9:30 AM
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Returns today's date with time set to midnight
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Returns yesterday's date
  static DateTime yesterday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - 1);
  }

  // Checks if an article date matches the selected date
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Returns "2 hours ago", "Just now", etc.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return formatShortDate(date);
  }
}