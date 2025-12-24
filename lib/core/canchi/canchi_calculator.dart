/// Can Chi (Stem-Branch) Calculator
/// Tính toán Can Chi cho năm, tháng, ngày, giờ
/// 
/// Migrated from TypeScript @lunar-calendar/core

import '../models/calendar_date.dart';
import '../models/can_chi.dart';
import '../constants.dart';
import '../lunar/lunar_calculator.dart' as lunar;

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Build CanChi object from can and chi indices
CanChi _buildCanChi(int can, int chi) {
  final canInfo = thienCan[can];
  final chiInfo = diaChi[chi];

  // Calculate the 60-year cycle index for Nạp Âm
  // In the 60-year cycle, each Can-Chi pair appears exactly once
  // The cycleIndex satisfies: cycleIndex ≡ can (mod 10) and cycleIndex ≡ chi (mod 12)
  // This is a Chinese Remainder Theorem problem
  // Solution: cycleIndex = (can - chi + 12) % 12 * 5 + chi
  // 
  // Verification:
  // - Giáp Tý (can=0, chi=0): (0-0+12)%12*5+0 = 0*5+0 = 0 ✓
  // - Ất Sửu (can=1, chi=1): (1-1+12)%12*5+1 = 0*5+1 = 1 ✓
  // - Bính Dần (can=2, chi=2): (2-2+12)%12*5+2 = 0*5+2 = 2 ✓
  // - Giáp Ngọ (can=0, chi=6): (0-6+12)%12*5+6 = 6*5+6 = 36 ✓
  final cycleIndex = ((can - chi + 12) % 12) * 5 + chi;
  
  // Calculate Nạp Âm index (each Nạp Âm appears twice in 60-year cycle)
  // So we divide by 2 to get the Nạp Âm index (0-29)
  // Ensure it's within valid range [0, 29]
  final napAmIndex = (cycleIndex ~/ 2) % 30;
  final napAmInfo = napAm[napAmIndex];

  return CanChi(
    can: can,
    chi: chi,
    canName: canInfo.name,
    chiName: chiInfo.name,
    fullName: '${canInfo.name} ${chiInfo.name}',
    element: napAmInfo.element,
    napAm: napAmInfo.name,
  );
}

/// Ensure positive modulo result
int _mod(int n, int m) {
  return ((n % m) + m) % m;
}

// =============================================================================
// CAN CHI CALCULATIONS
// =============================================================================

/// Get Can Chi for a lunar year
/// 
/// Formula: (năm âm - 4) mod 60
/// Năm Giáp Tý = năm 4 (Công nguyên)
/// 
/// Example:
/// ```dart
/// final yearCanChi = getYearCanChi(2024);
/// // CanChi(can: 0, chi: 4, fullName: 'Giáp Thìn', element: Element.moc)
/// ```
CanChi getYearCanChi(int lunarYear) {
  final offset = _mod(lunarYear - 4, 60);
  final can = offset % 10;
  final chi = offset % 12;
  return _buildCanChi(can, chi);
}

/// Get Can Chi for a lunar month
/// 
/// Can tháng phụ thuộc vào Can năm:
/// - Năm Giáp, Kỷ: tháng Giêng là Bính Dần
/// - Năm Ất, Canh: tháng Giêng là Mậu Dần
/// - Năm Bính, Tân: tháng Giêng là Canh Dần
/// - Năm Đinh, Nhâm: tháng Giêng là Nhâm Dần
/// - Năm Mậu, Quý: tháng Giêng là Giáp Dần
/// 
/// Chi tháng cố định: tháng Giêng = Dần (index 2)
CanChi getMonthCanChi(int lunarYear, int lunarMonth) {
  final yearCan = _mod(lunarYear - 4, 10);

  // Bảng tra Can tháng Giêng theo Can năm
  // Giáp/Kỷ -> Bính (2), Ất/Canh -> Mậu (4), etc.
  const monthCanStart = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0];
  final startCan = monthCanStart[yearCan];

  final can = _mod(startCan + lunarMonth - 1, 10);
  final chi = _mod(lunarMonth + 1, 12); // Tháng 1 = Dần (index 2)

  return _buildCanChi(can, chi);
}

/// Get Can Chi for a solar day
/// 
/// Based on Julian Day Number:
/// Can = (JD + 9) mod 10
/// Chi = (JD + 1) mod 12
/// 
/// Example:
/// ```dart
/// final dayCanChi = getDayCanChi(SolarDate(year: 2024, month: 2, day: 10));
/// ```
CanChi getDayCanChi(SolarDate solar) {
  final jd = lunar.toJulianDay(solar);
  final can = _mod(jd.toInt() + 9, 10);
  final chi = _mod(jd.toInt() + 1, 12);
  return _buildCanChi(can, chi);
}

/// Get Can Chi for an hour
/// 
/// Chi giờ cố định theo 12 canh:
/// - Tý: 23h-1h
/// - Sửu: 1h-3h
/// - Dần: 3h-5h
/// ...
/// 
/// Can giờ phụ thuộc Can ngày:
/// Can giờ Tý = (Can ngày * 2) mod 10
CanChi getHourCanChi(int dayCan, int hourChi) {
  // Can giờ Tý của mỗi Can ngày
  // Ngày Giáp, Kỷ: giờ Tý là Giáp Tý
  // Ngày Ất, Canh: giờ Tý là Bính Tý
  // Ngày Bính, Tân: giờ Tý là Mậu Tý
  // Ngày Đinh, Nhâm: giờ Tý là Canh Tý
  // Ngày Mậu, Quý: giờ Tý là Nhâm Tý
  const hourCanTyStart = [0, 2, 4, 6, 8, 0, 2, 4, 6, 8];
  final startCan = hourCanTyStart[dayCan];
  final can = _mod(startCan + hourChi, 10);

  return _buildCanChi(can, hourChi);
}

/// Get Chi from hour (0-23)
/// 
/// Returns the Chi index (0-11) for a given hour
int getChiFromHour(int hour) {
  // Hour 23 maps to Tý (0), hour 0-1 maps to Tý (0), etc.
  if (hour == 23) return 0;
  return (hour + 1) ~/ 2;
}

/// Get hour range from Chi
/// 
/// Returns start and end hour for a Chi
Map<String, int> getHourRangeFromChi(int chi) {
  final start = chi == 0 ? 23 : (chi * 2 - 1);
  final end = (chi * 2 + 1) % 24;
  return {'start': start, 'end': end};
}

/// Get full Can Chi information for a date
/// 
/// Returns Can Chi for year, month, day
Map<String, CanChi> getFullCanChi(SolarDate solar) {
  final lunarDate = lunar.solarToLunar(solar);
  final yearCanChi = getYearCanChi(lunarDate.year);
  final monthCanChi = getMonthCanChi(lunarDate.year, lunarDate.month);
  final dayCanChi = getDayCanChi(solar);

  return {
    'year': yearCanChi,
    'month': monthCanChi,
    'day': dayCanChi,
  };
}

