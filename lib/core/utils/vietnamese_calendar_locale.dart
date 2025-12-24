import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Vietnamese Calendar Locale Helper
/// Provides Vietnamese translations for table_calendar
class VietnameseCalendarLocale {
  /// Vietnamese month names
  static const List<String> monthNames = [
    'Tháng Một',
    'Tháng Hai',
    'Tháng Ba',
    'Tháng Tư',
    'Tháng Năm',
    'Tháng Sáu',
    'Tháng Bảy',
    'Tháng Tám',
    'Tháng Chín',
    'Tháng Mười',
    'Tháng Mười Một',
    'Tháng Mười Hai',
  ];

  /// Vietnamese short month names
  static const List<String> shortMonthNames = [
    'T1',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'T8',
    'T9',
    'T10',
    'T11',
    'T12',
  ];

  /// Vietnamese day names (full)
  static const List<String> dayNames = [
    'Chủ Nhật',
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
  ];

  /// Vietnamese short day names
  static const List<String> shortDayNames = [
    'CN',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
  ];

  /// Get Vietnamese month name
  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }

  /// Get Vietnamese short month name
  static String getShortMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return shortMonthNames[month - 1];
    }
    return '';
  }

  /// Get Vietnamese day name
  static String getDayName(int weekday) {
    // weekday: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    if (weekday >= 0 && weekday <= 6) {
      return dayNames[weekday];
    }
    return '';
  }

  /// Get Vietnamese short day name
  static String getShortDayName(int weekday) {
    if (weekday >= 0 && weekday <= 6) {
      return shortDayNames[weekday];
    }
    return '';
  }

  /// Format date to Vietnamese format
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  /// Format month year to Vietnamese
  static String formatMonthYear(DateTime date) {
    return '${getMonthName(date.month)} ${date.year}';
  }

  /// Get calendar format names in Vietnamese
  static Map<CalendarFormat, String> getCalendarFormatNames() {
    return {
      CalendarFormat.month: 'Tháng',
      CalendarFormat.twoWeeks: '2 Tuần',
      CalendarFormat.week: 'Tuần',
    };
  }
}

