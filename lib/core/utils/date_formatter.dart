import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String billDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String billDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final time = DateFormat('h:mm a').format(date);
    if (day == today) return 'Today, $time';
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == yesterday) return 'Yesterday, $time';
    return '${DateFormat('d MMM').format(date)}, $time';
  }

  static String receiptDay(DateTime date) => DateFormat('EEEE').format(date);
}
