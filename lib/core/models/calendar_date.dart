/// Core date models for Vietnamese Lunar Calendar
/// 
/// This file contains the basic date structures used throughout the app

/// Solar (Gregorian) Date
class SolarDate {
  final int year;
  final int month;
  final int day;

  const SolarDate({
    required this.year,
    required this.month,
    required this.day,
  });

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  factory SolarDate.fromDateTime(DateTime date) {
    return SolarDate(
      year: date.year,
      month: date.month,
      day: date.day,
    );
  }

  @override
  String toString() => '$year-$month-$day';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolarDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}

/// Lunar Date
class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;
  final String monthName;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeapMonth,
    required this.monthName,
  });

  @override
  String toString() => '$day/$month${isLeapMonth ? " (Nhuận)" : ""} $year';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LunarDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          isLeapMonth == other.isLeapMonth;

  @override
  int get hashCode =>
      year.hashCode ^
      month.hashCode ^
      day.hashCode ^
      isLeapMonth.hashCode;
}

