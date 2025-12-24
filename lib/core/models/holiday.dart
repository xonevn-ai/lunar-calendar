import 'calendar_date.dart';

/// Holiday types
enum HolidayType {
  public,      // Public holiday (fixed solar dates)
  traditional, // Traditional festival (lunar dates)
  religious,   // Religious holiday
}

/// Holiday model for Vietnamese holidays
class Holiday {
  final String id;
  final String name;
  final String vietnameseName;
  final HolidayType type;
  final SolarDate? solarDate;  // For fixed solar holidays
  final LunarDate? lunarDate;  // For lunar holidays (calculated)
  final bool isRecurring;
  final String? description;
  final String? icon; // Icon name or emoji
  
  Holiday({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.type,
    this.solarDate,
    this.lunarDate,
    this.isRecurring = true,
    this.description,
    this.icon,
  });
  
  /// Check if holiday occurs on a specific date
  bool occursOn(DateTime date) {
    if (solarDate != null) {
      // Fixed solar holiday
      return date.month == solarDate!.month && date.day == solarDate!.day;
    } else if (lunarDate != null) {
      // Lunar holiday - need to calculate
      // This will be handled by the repository
      return false; // Placeholder
    }
    return false;
  }
  
  /// Get display name
  String get displayName => vietnameseName.isNotEmpty ? vietnameseName : name;
}

