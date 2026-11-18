import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final DateFormat _editorialHeaderFormat = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortMonthDayFormat = DateFormat('dd MMM');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String formatEditorialHeader(DateTime dateTime) {
    return _editorialHeaderFormat.format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  static String formatShortMonthDay(DateTime dateTime) {
    return _shortMonthDayFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatRelativeOrDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final differenceInDays = today.difference(targetDate).inDays;

    if (differenceInDays == 0) {
      return 'Today, ${formatTime(dateTime)}';
    } else if (differenceInDays == 1) {
      return 'Yesterday, ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }

  static String getGreeting([DateTime? time]) {
    final now = time ?? DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    // Starting on Monday
    final daysToSubtract = date.weekday - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return startOfDay(monday);
  }

  static DateTime endOfWeek(DateTime date) {
    // Ending on Sunday
    final daysToAdd = 7 - date.weekday;
    final sunday = date.add(Duration(days: daysToAdd));
    return endOfDay(sunday);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0, 0, 0, 0);
  }

  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1, 0, 0, 0, 0, 0);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999, 999);
  }
}
