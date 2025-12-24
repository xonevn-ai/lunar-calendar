import '../../core/models/holiday.dart';
import '../../core/models/calendar_date.dart';
import '../../core/lunar/lunar_calculator.dart';

/// Holidays Repository
/// Manages Vietnamese holidays (both solar and lunar)
class HolidaysRepository {
  // Solar holidays (fixed dates)
  static final List<Holiday> _solarHolidays = [
    Holiday(
      id: 'new_year',
      name: 'New Year',
      vietnameseName: 'Tết Dương Lịch',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 1, day: 1),
      description: 'Ngày đầu năm mới theo dương lịch',
      icon: '🎉',
    ),
    Holiday(
      id: 'hung_kings',
      name: 'Hung Kings Festival',
      vietnameseName: 'Giỗ Tổ Hùng Vương',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 4, day: 10),
      description: 'Ngày giỗ tổ các vua Hùng',
      icon: '🏛️',
    ),
    Holiday(
      id: 'liberation_day',
      name: 'Liberation Day',
      vietnameseName: 'Ngày Giải phóng miền Nam',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 4, day: 30),
      description: 'Ngày thống nhất đất nước',
      icon: '🇻🇳',
    ),
    Holiday(
      id: 'labor_day',
      name: 'Labor Day',
      vietnameseName: 'Ngày Quốc tế Lao động',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 5, day: 1),
      description: 'Ngày quốc tế lao động',
      icon: '👷',
    ),
    Holiday(
      id: 'national_day',
      name: 'National Day',
      vietnameseName: 'Quốc khánh',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 9, day: 2),
      description: 'Ngày quốc khánh nước Cộng hòa Xã hội Chủ nghĩa Việt Nam',
      icon: '🇻🇳',
    ),
    Holiday(
      id: 'christmas',
      name: 'Christmas',
      vietnameseName: 'Giáng Sinh',
      type: HolidayType.religious,
      solarDate: SolarDate(year: 0, month: 12, day: 25),
      description: 'Lễ Giáng Sinh',
      icon: '🎄',
    ),
  ];
  
  // Lunar holidays (calculated dates)
  static final List<Holiday> _lunarHolidays = [
    Holiday(
      id: 'tet',
      name: 'Tet',
      vietnameseName: 'Tết Nguyên Đán',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 1, day: 1, isLeapMonth: false, monthName: ''),
      description: 'Tết cổ truyền Việt Nam - Ngày đầu năm mới âm lịch',
      icon: '🧧',
    ),
    Holiday(
      id: 'tet_2',
      name: 'Tet Day 2',
      vietnameseName: 'Mùng 2 Tết',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 1, day: 2, isLeapMonth: false, monthName: ''),
      description: 'Ngày thứ hai của Tết',
      icon: '🧧',
    ),
    Holiday(
      id: 'tet_3',
      name: 'Tet Day 3',
      vietnameseName: 'Mùng 3 Tết',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 1, day: 3, isLeapMonth: false, monthName: ''),
      description: 'Ngày thứ ba của Tết',
      icon: '🧧',
    ),
    Holiday(
      id: 'lantern_festival',
      name: 'Lantern Festival',
      vietnameseName: 'Tết Nguyên Tiêu',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 1, day: 15, isLeapMonth: false, monthName: ''),
      description: 'Rằm tháng Giêng',
      icon: '🏮',
    ),
    Holiday(
      id: 'hungry_ghost',
      name: 'Hungry Ghost Festival',
      vietnameseName: 'Tết Trung Nguyên',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 7, day: 15, isLeapMonth: false, monthName: ''),
      description: 'Rằm tháng Bảy - Lễ Vu Lan',
      icon: '🕯️',
    ),
    Holiday(
      id: 'mid_autumn',
      name: 'Mid-Autumn Festival',
      vietnameseName: 'Tết Trung Thu',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 8, day: 15, isLeapMonth: false, monthName: ''),
      description: 'Rằm tháng Tám - Tết Trung Thu',
      icon: '🌕',
    ),
    Holiday(
      id: 'double_ninth',
      name: 'Double Ninth Festival',
      vietnameseName: 'Tết Trùng Cửu',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 9, day: 9, isLeapMonth: false, monthName: ''),
      description: 'Mùng 9 tháng 9',
      icon: '🍂',
    ),
  ];
  
  /// Get all holidays
  static List<Holiday> getAllHolidays() {
    return [..._solarHolidays, ..._lunarHolidays];
  }
  
  /// Get holidays for a specific date
  static List<Holiday> getHolidaysForDate(DateTime date) {
    final holidays = <Holiday>[];
    final solar = SolarDate.fromDateTime(date);
    final lunar = solarToLunar(solar);
    
    // Check solar holidays
    for (final holiday in _solarHolidays) {
      if (holiday.solarDate != null) {
        if (date.month == holiday.solarDate!.month && 
            date.day == holiday.solarDate!.day) {
          holidays.add(holiday);
        }
      }
    }
    
    // Check lunar holidays
    for (final holiday in _lunarHolidays) {
      if (holiday.lunarDate != null) {
        if (lunar.month == holiday.lunarDate!.month && 
            lunar.day == holiday.lunarDate!.day &&
            !lunar.isLeapMonth) {
          holidays.add(holiday);
        }
      }
    }
    
    return holidays;
  }
  
  /// Get holidays for a month
  static List<Holiday> getHolidaysForMonth(DateTime month) {
    final holidays = <Holiday>[];
    final year = month.year;
    final monthNum = month.month;
    
    // Check solar holidays in this month
    for (final holiday in _solarHolidays) {
      if (holiday.solarDate != null && 
          holiday.solarDate!.month == monthNum) {
        holidays.add(holiday);
      }
    }
    
    // For lunar holidays, we need to check all days in the month
    // This is more complex, so we'll calculate for each day
    final daysInMonth = DateTime(year, monthNum + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, monthNum, day);
      final lunarHolidays = getHolidaysForDate(date)
          .where((h) => h.lunarDate != null)
          .toList();
      holidays.addAll(lunarHolidays);
    }
    
    return holidays.toSet().toList(); // Remove duplicates
  }
  
  /// Get holiday by ID
  static Holiday? getHolidayById(String id) {
    try {
      return getAllHolidays().firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }
}

