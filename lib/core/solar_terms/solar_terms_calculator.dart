/// Solar Terms (Tiết Khí) Calculator
/// 24 tiết khí trong năm
/// 
/// Migrated from TypeScript @lunar-calendar/core

import '../models/calendar_date.dart';
import '../models/solar_term.dart';
import '../constants.dart';

// =============================================================================
// PRE-COMPUTED SOLAR TERMS DATA
// =============================================================================

/// Base dates for solar terms (average dates)
/// Index = term index (0-23)
const List<Map<String, int>> solarTermBaseDates = [
  {'month': 1, 'day': 6},  // Tiểu Hàn
  {'month': 1, 'day': 20}, // Đại Hàn
  {'month': 2, 'day': 4},  // Lập Xuân
  {'month': 2, 'day': 19}, // Vũ Thủy
  {'month': 3, 'day': 6},  // Kinh Trập
  {'month': 3, 'day': 21}, // Xuân Phân
  {'month': 4, 'day': 5},  // Thanh Minh
  {'month': 4, 'day': 20}, // Cốc Vũ
  {'month': 5, 'day': 6},  // Lập Hạ
  {'month': 5, 'day': 21}, // Tiểu Mãn
  {'month': 6, 'day': 6},  // Mang Chủng
  {'month': 6, 'day': 21}, // Hạ Chí
  {'month': 7, 'day': 7},  // Tiểu Thử
  {'month': 7, 'day': 23}, // Đại Thử
  {'month': 8, 'day': 7},  // Lập Thu
  {'month': 8, 'day': 23}, // Xử Thử
  {'month': 9, 'day': 8},  // Bạch Lộ
  {'month': 9, 'day': 23}, // Thu Phân
  {'month': 10, 'day': 8}, // Hàn Lộ
  {'month': 10, 'day': 23}, // Sương Giáng
  {'month': 11, 'day': 7}, // Lập Đông
  {'month': 11, 'day': 22}, // Tiểu Tuyết
  {'month': 12, 'day': 7}, // Đại Tuyết
  {'month': 12, 'day': 22}, // Đông Chí
];

// =============================================================================
// CALCULATION FUNCTIONS
// =============================================================================

/// Calculate solar term date for a specific year
/// Uses simplified astronomical calculation
/// 
/// This approximation is accurate to ±1 day
SolarDate _calculateSolarTermDate(int year, int termIndex) {
  final base = solarTermBaseDates[termIndex];
  final baseMonth = base['month']!;
  final baseDay = base['day']!;

  // Simplified calculation
  final century = year ~/ 100;
  final yearInCentury = year % 100;

  // Adjustment based on year
  int dayOffset = 0;

  // Leap year adjustment
  if (termIndex >= 0 && termIndex <= 3) {
    // Jan-Feb terms
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    if (isLeapYear && termIndex >= 2) {
      dayOffset -= 1;
    }
  }

  // Century adjustment (simplified)
  if (century == 20) {
    dayOffset += (yearInCentury - 1) ~/ 4;
  } else if (century == 21) {
    dayOffset += yearInCentury ~/ 4;
  }

  // Normalize day offset
  dayOffset = dayOffset % 2;

  var day = baseDay + dayOffset;
  var month = baseMonth;

  // Handle month overflow
  final daysInMonth = DateTime(year, month + 1, 0).day;
  if (day > daysInMonth) {
    day -= daysInMonth;
    month += 1;
  }

  return SolarDate(year: year, month: month, day: day);
}

/// Get all 24 solar terms for a year
/// 
/// Example:
/// ```dart
/// final terms = getSolarTermsInYear(2024);
/// Debug: Uncomment to print solar terms
/// terms.forEach((t) => debugPrint('${t.name}: ${t.date}'));
/// ```
List<SolarTerm> getSolarTermsInYear(int year) {
  return solarTermsBase.map((term) {
    final calculatedDate = _calculateSolarTermDate(year, term.index);
    return SolarTerm(
      index: term.index,
      name: term.name,
      chineseName: term.chineseName,
      date: calculatedDate,
      description: term.description,
    );
  }).toList();
}

/// Get the solar term that falls on or contains a specific date
/// 
/// Returns SolarTerm if the date is a solar term date, null otherwise
SolarTerm? getSolarTermOnDate(SolarDate solar) {
  final terms = getSolarTermsInYear(solar.year);

  for (final term in terms) {
    if (term.date.year == solar.year &&
        term.date.month == solar.month &&
        term.date.day == solar.day) {
      return term;
    }
  }

  return null;
}

/// Get the current solar term period for a date
/// 
/// Returns the most recent solar term before or on this date
SolarTerm getCurrentSolarTerm(SolarDate solar) {
  final terms = getSolarTermsInYear(solar.year);
  final prevYearTerms = getSolarTermsInYear(solar.year - 1);

  // Convert date to comparable number
  int dateNum(SolarDate d) => d.year * 10000 + d.month * 100 + d.day;
  final targetNum = dateNum(solar);

  // Find the most recent term before or on this date
  var currentTerm = prevYearTerms[23]; // Default to last term of previous year

  for (final term in terms) {
    final termNum = dateNum(term.date);
    if (termNum <= targetNum) {
      currentTerm = term;
    } else {
      break;
    }
  }

  return currentTerm;
}

/// Get the next solar term after a date
SolarTerm getNextSolarTerm(SolarDate solar) {
  final terms = getSolarTermsInYear(solar.year);
  final nextYearTerms = getSolarTermsInYear(solar.year + 1);

  int dateNum(SolarDate d) => d.year * 10000 + d.month * 100 + d.day;
  final targetNum = dateNum(solar);

  for (final term in terms) {
    if (dateNum(term.date) > targetNum) {
      return term;
    }
  }

  // Return first term of next year
  return nextYearTerms[0];
}

/// Get days until next solar term
int getDaysUntilNextTerm(SolarDate solar) {
  final nextTerm = getNextSolarTerm(solar);

  final currentDate = DateTime(solar.year, solar.month, solar.day);
  final termDate = DateTime(
    nextTerm.date.year,
    nextTerm.date.month,
    nextTerm.date.day,
  );

  return termDate.difference(currentDate).inDays;
}

/// Get solar term by name
/// 
/// Returns SolarTerm or null if not found
SolarTerm? getSolarTermByName(String name, int year) {
  final terms = getSolarTermsInYear(year);
  try {
    return terms.firstWhere((t) => t.name == name);
  } catch (e) {
    return null;
  }
}

