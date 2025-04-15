import 'package:intl/intl.dart';

/// Utility class for formatting dates in a consistent way
class DateFormatter {
  /// Format a date in a human-readable format like "Jan 1, 2023"
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
  
  /// Format a date in a relative way (e.g., "2 days ago", "Just now")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Format a time in 12-hour format with AM/PM (e.g., "3:30 PM")
  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }
  
  /// Format a date and time together (e.g., "Jan 1, 2023 at 3:30 PM")
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }
}