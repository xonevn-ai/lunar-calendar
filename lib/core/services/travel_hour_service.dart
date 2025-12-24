import '../models/calendar_date.dart';
import '../models/travel_hour.dart';
import '../models/hour_info.dart';
import '../models/can_chi.dart';
import '../hoangdao/hoangdao_service.dart';
import '../canchi/canchi_calculator.dart';

/// Travel Hour Service
/// Calculates hour-by-hour travel guidance according to Lý Thuần Phong
class TravelHourService {
  /// Get travel hours for a date
  /// Returns hour-by-hour guidance based on traditional calculations
  static List<TravelHour> getTravelHoursForDate(SolarDate solarDate) {
    final hours = getHoangDaoHours(solarDate);
    final dayCanChi = getDayCanChi(solarDate);
    
    final travelHours = <TravelHour>[];
    
    for (final hour in hours) {
      final travelHour = _calculateTravelHour(hour, dayCanChi);
      travelHours.add(travelHour);
    }
    
    return travelHours;
  }
  
  /// Calculate travel guidance for a specific hour
  static TravelHour _calculateTravelHour(HourInfo hour, CanChi dayCanChi) {
    final isGood = hour.type == HourType.hoangdao;
    final hourChi = hour.chi;
    
    // Simplified calculation based on hour Chi and day Can Chi
    // Real Lý Thuần Phong calculations are more complex
    String description;
    List<String> activities;
    String? direction;
    String? warning;
    
    // Calculate based on hour Chi
    switch (hourChi) {
      case 0: // Tý (23h-01h)
        if (isGood) {
          description = 'Tin vui sắp tới, mọi việc đều thuận lợi';
          activities = ['Xuất hành', 'Gặp gỡ', 'Ký kết hợp đồng'];
          direction = 'Bắc';
        } else {
          description = 'Cần thận trọng, tránh tranh cãi';
          activities = ['Tránh xuất hành xa', 'Tránh tranh luận'];
          warning = 'Dễ gặp rủi ro';
        }
        break;
        
      case 1: // Sửu (01h-03h)
        if (isGood) {
          description = 'Cơ hội tốt, nên hành động nhanh';
          activities = ['Khởi công', 'Xuất hành buổi sáng'];
          direction = 'Đông Bắc';
        } else {
          description = 'Hay tranh luận, cãi cọ';
          activities = ['Tránh tranh luận', 'Tránh kiện tụng'];
          warning = 'Dễ xảy ra mâu thuẫn';
        }
        break;
        
      case 2: // Dần (03h-05h)
        if (isGood) {
          description = 'Ngày mới bắt đầu, mọi việc đều tốt';
          activities = ['Xuất hành', 'Khởi công', 'Học tập'];
          direction = 'Đông Bắc';
        } else {
          description = 'Cần cẩn thận với tài sản';
          activities = ['Tránh đầu tư lớn', 'Tránh cho vay'];
          warning = 'Dễ mất mát tài sản';
        }
        break;
        
      case 3: // Mão (05h-07h)
        if (isGood) {
          description = 'Thời điểm tốt cho công việc';
          activities = ['Làm việc', 'Học tập', 'Xuất hành'];
          direction = 'Đông';
        } else {
          description = 'Tránh quyết định quan trọng';
          activities = ['Tránh ký kết', 'Tránh đầu tư'];
          warning = 'Dễ đưa ra quyết định sai';
        }
        break;
        
      case 4: // Thìn (07h-09h)
        if (isGood) {
          description = 'Năng lượng tích cực, mọi việc hanh thông';
          activities = ['Gặp gỡ', 'Ký kết', 'Xuất hành'];
          direction = 'Đông Nam';
        } else {
          description = 'Cần kiên nhẫn, tránh vội vàng';
          activities = ['Tránh vội vàng', 'Tránh tranh cãi'];
          warning = 'Dễ mắc sai lầm do vội vàng';
        }
        break;
        
      case 5: // Tỵ (09h-11h)
        if (isGood) {
          description = 'Thời điểm tốt cho giao dịch';
          activities = ['Giao dịch', 'Ký kết', 'Xuất hành'];
          direction = 'Đông Nam';
        } else {
          description = 'Tránh đầu tư rủi ro';
          activities = ['Tránh đầu tư', 'Tránh cho vay'];
          warning = 'Dễ gặp rủi ro tài chính';
        }
        break;
        
      case 6: // Ngọ (11h-13h)
        if (isGood) {
          description = 'Tin vui sắp tới, mọi việc đều thuận lợi';
          activities = ['Xuất hành', 'Gặp gỡ', 'Ký kết hợp đồng'];
          direction = 'Nam';
        } else {
          description = 'Cần thận trọng, tránh tranh cãi';
          activities = ['Tránh xuất hành xa', 'Tránh tranh luận'];
          warning = 'Dễ gặp rủi ro';
        }
        break;
        
      case 7: // Mùi (13h-15h)
        if (isGood) {
          description = 'Cơ hội tốt, nên hành động nhanh';
          activities = ['Khởi công', 'Xuất hành buổi chiều'];
          direction = 'Tây Nam';
        } else {
          description = 'Hay tranh luận, cãi cọ';
          activities = ['Tránh tranh luận', 'Tránh kiện tụng'];
          warning = 'Dễ xảy ra mâu thuẫn';
        }
        break;
        
      case 8: // Thân (15h-17h)
        if (isGood) {
          description = 'Thời điểm tốt cho công việc';
          activities = ['Làm việc', 'Gặp gỡ', 'Xuất hành'];
          direction = 'Tây Nam';
        } else {
          description = 'Cần cẩn thận với tài sản';
          activities = ['Tránh đầu tư lớn', 'Tránh cho vay'];
          warning = 'Dễ mất mát tài sản';
        }
        break;
        
      case 9: // Dậu (17h-19h)
        if (isGood) {
          description = 'Năng lượng tích cực, mọi việc hanh thông';
          activities = ['Gặp gỡ', 'Ký kết', 'Xuất hành'];
          direction = 'Tây';
        } else {
          description = 'Tránh quyết định quan trọng';
          activities = ['Tránh ký kết', 'Tránh đầu tư'];
          warning = 'Dễ đưa ra quyết định sai';
        }
        break;
        
      case 10: // Tuất (19h-21h)
        if (isGood) {
          description = 'Thời điểm tốt cho giao dịch';
          activities = ['Giao dịch', 'Ký kết', 'Xuất hành'];
          direction = 'Tây Bắc';
        } else {
          description = 'Cần kiên nhẫn, tránh vội vàng';
          activities = ['Tránh vội vàng', 'Tránh tranh cãi'];
          warning = 'Dễ mắc sai lầm do vội vàng';
        }
        break;
        
      case 11: // Hợi (21h-23h)
        if (isGood) {
          description = 'Kết thúc ngày tốt, nghỉ ngơi';
          activities = ['Nghỉ ngơi', 'Gia đình', 'Tránh xuất hành xa'];
          direction = 'Tây Bắc';
        } else {
          description = 'Tránh đầu tư rủi ro';
          activities = ['Tránh đầu tư', 'Tránh cho vay'];
          warning = 'Dễ gặp rủi ro tài chính';
        }
        break;
        
      default:
        description = 'Thông tin chưa có';
        activities = [];
    }
    
    return TravelHour(
      hour: hour,
      description: description,
      isGood: isGood,
      direction: direction,
      activities: activities,
      warning: warning,
    );
  }
  
  /// Get good travel hours for a date
  static List<TravelHour> getGoodTravelHours(SolarDate solarDate) {
    final allHours = getTravelHoursForDate(solarDate);
    return allHours.where((h) => h.isGood).toList();
  }
  
  /// Get bad travel hours for a date
  static List<TravelHour> getBadTravelHours(SolarDate solarDate) {
    final allHours = getTravelHoursForDate(solarDate);
    return allHours.where((h) => !h.isGood).toList();
  }
}

