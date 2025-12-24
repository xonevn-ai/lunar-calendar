/// Hoàng Đạo / Hắc Đạo Service
/// Tính toán giờ hoàng đạo, hắc đạo, trực
/// 
/// Updated based on Vietnamese lunar calendar calculation
/// Uses binary pattern matching for accurate hour determination

import '../models/calendar_date.dart';
import '../models/hour_info.dart';
import '../models/truc_info.dart';
import '../constants.dart';
import '../canchi/canchi_calculator.dart';
import '../lunar/lunar_calculator.dart' as lunar;

// =============================================================================
// HOÀNG ĐẠO GIỜ (HOUR STARS)
// =============================================================================

/// Good hours pattern (binary string, 1 = hoàng đạo, 0 = hắc đạo)
/// Pattern repeats every 6 Chi values
/// Based on Vietnamese lunar calendar calculation
const List<String> goodHoursPattern = [
  '110100101100', // Tý, Ngọ
  '001101001011', // Sửu, Mùi
  '110011010010', // Dần, Thân
  '101100110100', // Mão, Dậu
  '001011001101', // Thìn, Tuất
  '010010110011', // Tỵ, Hợi
];

/// Get all 12 hour information for a day
/// 
/// Uses binary pattern matching based on day's Chi
/// 
/// Example:
/// ```dart
/// final hours = getHoangDaoHours(SolarDate(year: 2025, month: 12, day: 23));
/// // For Bính Dần day: Tý, Sửu, Thìn, Tỵ, Mùi, Tuất are hoàng đạo
/// ```
List<HourInfo> getHoangDaoHours(SolarDate solar) {
  final dayCanChi = getDayCanChi(solar);
  final dayChi = dayCanChi.chi;
  final dayCan = dayCanChi.can;

  // Get pattern based on day's Chi (pattern repeats every 6)
  final patternIndex = dayChi % 6;
  final pattern = goodHoursPattern[patternIndex];

  // Get starting star index for hour Tý based on day's Chi (for star names)
  final startStarIndex = hourStarStartTable[dayChi];

  final hours = <HourInfo>[];

  for (int hourChi = 0; hourChi < 12; hourChi++) {
    // Check if this hour is hoàng đạo based on pattern
    final isHoangDao = pattern[hourChi] == '1';
    
    // Get star information (for display purposes)
    final starIndex = (startStarIndex + hourChi) % 12;
    final star = hoangDaoStars[starIndex];
    
    final hourRange = getHourRangeFromChi(hourChi);
    final hourCanChi = getHourCanChi(dayCan, hourChi);

    hours.add(HourInfo(
      chi: hourChi,
      chiName: diaChi[hourChi].name,
      startHour: hourRange['start']!,
      endHour: hourRange['end']!,
      type: isHoangDao ? HourType.hoangdao : HourType.hacdao,
      starName: star.name,
      meaning: star.meaning,
      canChi: hourCanChi,
    ));
  }

  return hours;
}

/// Get hoàng đạo hours only
List<HourInfo> getGoodHours(SolarDate solar) {
  return getHoangDaoHours(solar)
      .where((h) => h.type == HourType.hoangdao)
      .toList();
}

/// Get hắc đạo hours only
List<HourInfo> getBadHours(SolarDate solar) {
  return getHoangDaoHours(solar)
      .where((h) => h.type == HourType.hacdao)
      .toList();
}

/// Check if current hour is hoàng đạo
/// 
/// [hour] is 0-23 (24-hour format)
bool isHoangDaoHour(SolarDate solar, int hour) {
  final dayCanChi = getDayCanChi(solar);
  final dayChi = dayCanChi.chi;
  
  // Get pattern based on day's Chi
  final patternIndex = dayChi % 6;
  final pattern = goodHoursPattern[patternIndex];
  
  // Convert hour (0-23) to Chi (0-11)
  final hourChi = hour == 23 ? 0 : (hour + 1) ~/ 2;
  
  return pattern[hourChi] == '1';
}

// =============================================================================
// TRỰC (DAY QUALITY)
// =============================================================================

/// Get Trực (day quality) for a date
/// 
/// Trực được tính dựa trên Chi ngày và Chi tháng:
/// - Tháng Giêng (Dần): ngày Dần là Kiến
/// - Tháng Hai (Mão): ngày Mão là Kiến
/// ...
TrucInfo getTruc(SolarDate solar) {
  final lunarDate = lunar.solarToLunar(solar);
  final dayCanChi = getDayCanChi(solar);

  // Chi tháng (tháng Giêng = Dần = 2)
  final monthChi = (lunarDate.month + 1) % 12;

  // Chi ngày
  final dayChi = dayCanChi.chi;

  // Trực index = (Chi ngày - Chi tháng + 12) mod 12
  final trucIndex = (dayChi - monthChi + 12) % 12;

  return trucInfo[trucIndex];
}

/// Check if a day is hoàng đạo day (based on Trực)
/// 
/// Hoàng đạo days: Trừ, Định, Chấp, Thành, Khai
/// Hắc đạo days: Kiến, Mãn, Bình, Phá, Nguy, Thu, Bế
bool isHoangDaoDay(SolarDate solar) {
  final truc = getTruc(solar);
  return truc.type == TrucType.hoangdao;
}

/// Get day quality summary
Map<String, dynamic> getDayQuality(SolarDate solar) {
  final truc = getTruc(solar);
  final hours = getHoangDaoHours(solar);

  return {
    'truc': truc,
    'isHoangDaoDay': truc.type == TrucType.hoangdao,
    'hoangDaoHours': hours.where((h) => h.type == HourType.hoangdao).toList(),
    'hacDaoHours': hours.where((h) => h.type == HourType.hacdao).toList(),
  };
}

// =============================================================================
// SEARCH FUNCTIONS
// =============================================================================

/// Find hoàng đạo days in a month
List<SolarDate> findHoangDaoDaysInMonth(int year, int month) {
  final result = <SolarDate>[];
  final daysInMonth = DateTime(year, month + 1, 0).day;

  for (int day = 1; day <= daysInMonth; day++) {
    final date = SolarDate(year: year, month: month, day: day);
    if (isHoangDaoDay(date)) {
      result.add(date);
    }
  }

  return result;
}

/// Find days good for a specific activity
List<SolarDate> findGoodDaysFor(int year, int month, String activity) {
  final result = <SolarDate>[];
  final daysInMonth = DateTime(year, month + 1, 0).day;

  for (int day = 1; day <= daysInMonth; day++) {
    final date = SolarDate(year: year, month: month, day: day);
    final truc = getTruc(date);

    if (truc.goodFor.any((g) => g.toLowerCase().contains(activity.toLowerCase()))) {
      result.add(date);
    }
  }

  return result;
}

