import 'package:intl/intl.dart';

class DateFormatter {
  String short(DateTime date) {
    final DateTime localDate = date.toLocal();
    final DateTime now = DateTime.now();

    // Just now
    final DateTime justNow = now.subtract(const Duration(minutes: 1));
    if (!localDate.difference(justNow).isNegative) {
      return 'Just now';
    }

    // Yesterday
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (localDate.year == yesterday.year && localDate.month == yesterday.month && localDate.day == yesterday.day) {
      return 'Yesterday ${DateFormat.Hm().format(localDate)}';
    }

    if (now.year == localDate.year) {
      if (now.month == localDate.month) {
        if (now.day == localDate.day) {
          return DateFormat.Hm().format(localDate);
        } else {
          // Another date this month
          return DateFormat.MMMd().format(localDate);
        }
      } else {
        // Another month this year
        return DateFormat.MMMd().format(localDate);
      }
    } else {
      // Past year
      return DateFormat('d/M/y').format(localDate);
    }
  }
}
