/// Lunar Calendar Calculator (Vietnamese)
/// Chuyển đổi giữa âm lịch và dương lịch
/// 
/// Based on astronomical algorithms from "Astronomical Algorithms" by Jean Meeus, 1998
/// Adapted from lunar_calendar_plus package (https://github.com/Nghi-NV/lunar_calendar)
/// 
/// This algorithm calculates lunar dates based on new moon calculations
/// and is more accurate than lookup table approach, especially for Vietnamese calendar
/// which uses UTC+7 timezone (105° East longitude)

import 'dart:math' as math;
import '../models/calendar_date.dart';
import '../constants.dart';

// =============================================================================
// CONSTANTS
// =============================================================================

/// Vietnamese timezone (UTC+7)
const double vietnamTimeZone = 7.0;

/// Julian Day Number for 1/1/1900 13:52 UTC
const double jd1900 = 2415021.076998695;

// =============================================================================
// VALIDATION
// =============================================================================

/// Validate solar date
void validateSolarDate(SolarDate date) {
  if (date.year < minYear || date.year > maxYear) {
    throw ArgumentError(
      'Year ${date.year} is out of supported range ($minYear-$maxYear)',
    );
  }

  if (date.month < 1 || date.month > 12) {
    throw ArgumentError('Month ${date.month} is invalid (must be 1-12)');
  }

  final daysInMonth = getDaysInSolarMonth(date.year, date.month);
  if (date.day < 1 || date.day > daysInMonth) {
    throw ArgumentError(
      'Day ${date.day} is invalid for month ${date.month}/${date.year}',
    );
  }
}

/// Validate lunar date
void validateLunarDate(LunarDate date) {
  if (date.year < minYear || date.year > maxYear) {
    throw ArgumentError(
      'Year ${date.year} is out of supported range ($minYear-$maxYear)',
    );
  }

  if (date.month < 1 || date.month > 12) {
    throw ArgumentError('Month ${date.month} is invalid (must be 1-12)');
  }

  if (date.day < 1 || date.day > 30) {
    throw ArgumentError('Day ${date.day} is invalid (must be 1-30)');
  }
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/// Convert double to int (floor)
int _toInt(double d) => d.floor();

/// Check if a year is a leap year (solar calendar)
bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}

/// Get number of days in a solar month
int getDaysInSolarMonth(int year, int month) {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && isLeapYear(year)) {
    return 29;
  }
  return days[month - 1];
}

/// Calculate Julian Day Number from solar date
int jdFromDate(int day, int month, int year) {
  final a = _toInt((14 - month) / 12);
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  var jd = day +
      _toInt((153 * m + 2) / 5) +
      365 * y +
      _toInt(y / 4) -
      _toInt(y / 100) +
      _toInt(y / 400) -
      32045;

  if (jd < 2299161) {
    jd = day + _toInt((153 * m + 2) / 5) + 365 * y + _toInt(y / 4) - 32083;
  }
  return jd;
}

/// Convert Julian Day Number to solar date
List<int> jdToDate(int jd) {
  int a, b, c;
  if (jd > 2299160) {
    a = jd + 32044;
    b = _toInt((4 * a + 3) / 146097);
    c = a - _toInt((b * 146097) / 4);
  } else {
    b = 0;
    c = jd + 32082;
  }

  final d = _toInt((4 * c + 3) / 1461);
  final e = c - _toInt((1461 * d) / 4);
  final m = _toInt((5 * e + 2) / 153);
  final day = e - _toInt((153 * m + 2) / 5) + 1;
  final month = m + 3 - 12 * _toInt(m / 10);
  final year = b * 100 + d - 4800 + _toInt(m / 10);

  return [day, month, year];
}

/// Convert solar date to Julian Day Number (for compatibility)
double toJulianDay(SolarDate date) {
  return jdFromDate(date.day, date.month, date.year).toDouble();
}

/// Convert Julian Day Number to solar date (for compatibility)
SolarDate fromJulianDay(double jd) {
  final date = jdToDate(jd.toInt());
  return SolarDate(year: date[2], month: date[1], day: date[0]);
}

// =============================================================================
// ASTRONOMICAL CALCULATIONS
// =============================================================================

/// Compute the time of the k-th new moon after the new moon of 1/1/1900 13:52 UTC
/// Algorithm from: "Astronomical Algorithms" by Jean Meeus, 1998
double newMoon(int k) {
  double T, T2, T3, dr, Jd1, M, Mpr, F, C1, delta, JdNew;
  T = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
  T2 = T * T;
  T3 = T2 * T;
  dr = math.pi / 180;
  Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
  Jd1 = Jd1 +
      0.00033 *
          math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr); // Mean new moon
  M = 359.2242 +
      29.10535608 * k -
      0.0000333 * T2 -
      0.00000347 * T3; // Sun's mean anomaly
  Mpr = 306.0253 +
      385.81691806 * k +
      0.0107306 * T2 +
      0.00001236 * T3; // Moon's mean anomaly
  F = 21.2964 +
      390.67050646 * k -
      0.0016528 * T2 -
      0.00000239 * T3; // Moon's argument of latitude
  C1 = (0.1734 - 0.000393 * T) * math.sin(M * dr) + 0.0021 * math.sin(2 * dr * M);
  C1 = C1 - 0.4068 * math.sin(Mpr * dr) + 0.0161 * math.sin(dr * 2 * Mpr);
  C1 = C1 - 0.0004 * math.sin(dr * 3 * Mpr);
  C1 = C1 + 0.0104 * math.sin(dr * 2 * F) - 0.0051 * math.sin(dr * (M + Mpr));
  C1 = C1 - 0.0074 * math.sin(dr * (M - Mpr)) + 0.0004 * math.sin(dr * (2 * F + M));
  C1 = C1 - 0.0004 * math.sin(dr * (2 * F - M)) - 0.0006 * math.sin(dr * (2 * F + Mpr));
  C1 = C1 +
      0.0010 * math.sin(dr * (2 * F - Mpr)) +
      0.0005 * math.sin(dr * (2 * Mpr + M));
  if (T < -11) {
    delta = 0.001 +
        0.000839 * T +
        0.0002261 * T2 -
        0.00000845 * T3 -
        0.000000081 * T * T3;
  } else {
    delta = -0.000278 + 0.000265 * T + 0.000262 * T2;
  }
  JdNew = Jd1 + C1 - delta;
  return JdNew;
}

/// Compute the longitude of the sun at any time
/// Algorithm from: "Astronomical Algorithms" by Jean Meeus, 1998
double sunLongitude(double jdn) {
  double T, T2, dr, M, L0, DL, L;
  T = (jdn - 2451545.0) /
      36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
  T2 = T * T;
  dr = math.pi / 180; // degree to radian
  M = 357.52910 +
      35999.05030 * T -
      0.0001559 * T2 -
      0.00000048 * T * T2; // mean anomaly, degree
  L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2; // mean longitude, degree
  DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * math.sin(dr * M);
  DL = DL +
      (0.019993 - 0.000101 * T) * math.sin(dr * 2 * M) +
      0.000290 * math.sin(dr * 3 * M);
  L = L0 + DL; // true longitude, degree
  L = L * dr;
  L = L - math.pi * 2 * (_toInt(L / (math.pi * 2)));
  return L;
}

/// Compute sun position at midnight of the day with the given Julian day number
/// Returns a number between 0 and 11 (solar term index)
int getSunLongitude(double dayNumber, double timeZone) {
  return _toInt(sunLongitude(dayNumber - 0.5 - timeZone / 24) / math.pi * 6);
}

/// Compute the day of the k-th new moon in the given time zone
int getNewMoonDay(int k, double timeZone) {
  return _toInt(newMoon(k) + 0.5 + timeZone / 24);
}

/// Find the day that starts the lunar month 11 of the given year for the given time zone
int getLunarMonth11(int year, double timeZone) {
  int k, off, nm, sunLong;
  off = jdFromDate(31, 12, year) - 2415021;
  k = _toInt(off / 29.530588853);
  nm = getNewMoonDay(k, timeZone);
  sunLong = getSunLongitude(
      nm.toDouble(), timeZone); // sun longitude at local midnight
  if (sunLong >= 9) {
    nm = getNewMoonDay(k - 1, timeZone);
  }
  return nm;
}

/// Find the index of the leap month after the month starting on the day a11
int getLeapMonthOffset(int a11, double timeZone) {
  int k, last, arc, i;
  k = _toInt((a11 - jd1900) / 29.530588853 + 0.5);
  last = 0;
  i = 1; // We start with the month following lunar month 11
  arc = getSunLongitude(getNewMoonDay(k + i, timeZone).toDouble(), timeZone);
  do {
    last = arc;
    i++;
    arc =
        getSunLongitude(getNewMoonDay(k + i, timeZone).toDouble(), timeZone);
  } while (arc != last && i < 14);
  return i - 1;
}

// =============================================================================
// MAIN CONVERSION FUNCTIONS
// =============================================================================

/// Convert solar date to lunar date
/// 
/// Uses astronomical algorithms based on new moon calculations
/// Timezone: UTC+7 (Vietnam)
/// 
/// Example:
/// ```dart
/// final solar = SolarDate(year: 2025, month: 12, day: 23);
/// final lunar = solarToLunar(solar);
/// // Should be: LunarDate(year: 2025, month: 11, day: 4, isLeapMonth: false)
/// ```
LunarDate solarToLunar(SolarDate solar, {double timeZone = vietnamTimeZone}) {
  validateSolarDate(solar);

  final day = solar.day;
  final month = solar.month;
  final year = solar.year;

  final dayNumber = jdFromDate(day, month, year);
  final k = _toInt((dayNumber - jd1900) / 29.530588853);
  var monthStart = getNewMoonDay(k + 1, timeZone);

  if (monthStart > dayNumber) {
    monthStart = getNewMoonDay(k, timeZone);
  }

  var a11 = getLunarMonth11(year, timeZone);
  final b11 = a11;

  int lunarYear;
  if (a11 >= monthStart) {
    lunarYear = year;
    a11 = getLunarMonth11(year - 1, timeZone);
  } else {
    lunarYear = year + 1;
  }

  final lunarDay = dayNumber - monthStart + 1;
  final diff = _toInt((monthStart - a11) / 29);
  var lunarLeap = 0;
  var lunarMonth = diff + 11;

  if (b11 - a11 > 365) {
    final leapMonthDiff = getLeapMonthOffset(a11, timeZone);
    if (diff >= leapMonthDiff) {
      lunarMonth = diff + 10;
      if (diff == leapMonthDiff) {
        lunarLeap = 1;
      }
    }
  }

  if (lunarMonth > 12) {
    lunarMonth = lunarMonth - 12;
  }
  if (lunarMonth >= 11 && diff < 4) {
    lunarYear -= 1;
  }

  return LunarDate(
    year: lunarYear,
    month: lunarMonth,
    day: lunarDay,
    isLeapMonth: lunarLeap == 1,
    monthName: lunarMonthNames[lunarMonth - 1],
  );
}

/// Convert lunar date to solar date
/// 
/// Uses astronomical algorithms based on new moon calculations
/// Timezone: UTC+7 (Vietnam)
/// 
/// Example:
/// ```dart
/// final lunar = LunarDate(
///   year: 2025,
///   month: 11,
///   day: 4,
///   isLeapMonth: false,
/// );
/// final solar = lunarToSolar(lunar);
/// // Should be: SolarDate(year: 2025, month: 12, day: 23)
/// ```
SolarDate lunarToSolar(LunarDate lunar, {double timeZone = vietnamTimeZone}) {
  validateLunarDate(lunar);

  int k, a11, b11, off, leapOff, leapMonth, monthStart;
  if (lunar.month < 11) {
    a11 = getLunarMonth11(lunar.year - 1, timeZone);
    b11 = getLunarMonth11(lunar.year, timeZone);
  } else {
    a11 = getLunarMonth11(lunar.year, timeZone);
    b11 = getLunarMonth11(lunar.year + 1, timeZone);
  }
  k = _toInt(0.5 + (a11 - jd1900) / 29.530588853);
  off = lunar.month - 11;
  if (off < 0) {
    off += 12;
  }
  if (b11 - a11 > 365) {
    leapOff = getLeapMonthOffset(a11, timeZone);
    leapMonth = leapOff - 2;
    if (leapMonth < 0) {
      leapMonth += 12;
    }
    if (lunar.isLeapMonth && lunar.month != leapMonth) {
      throw ArgumentError('Invalid leap month: ${lunar.month} is not a leap month in year ${lunar.year}');
    } else if (lunar.isLeapMonth || off >= leapOff) {
      off += 1;
    }
  }
  monthStart = getNewMoonDay(k + off, timeZone);
  final date = jdToDate(monthStart + lunar.day - 1);
  return SolarDate(year: date[2], month: date[1], day: date[0]);
}

/// Get days from start of year to a date (for compatibility)
int getDayOfYear(SolarDate date) {
  int days = date.day;
  for (int m = 1; m < date.month; m++) {
    days += getDaysInSolarMonth(date.year, m);
  }
  return days;
}
