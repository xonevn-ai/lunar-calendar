import '../models/calendar_date.dart';
import '../models/travel_direction.dart';
import '../canchi/canchi_calculator.dart';

/// Travel Direction Service
/// Calculates auspicious and inauspicious directions for travel
class TravelDirectionService {
  /// Get travel directions for a date
  /// Based on Can Chi and traditional calculations
  static List<TravelDirection> getDirectionsForDate(SolarDate solarDate) {
    final dayCanChi = getDayCanChi(solarDate);
    
    // Simplified calculation based on Can Chi
    // Real calculation is more complex and involves multiple factors
    final directions = <TravelDirection>[];
    
    // Calculate based on Can Chi combination
    final canIndex = dayCanChi.can;
    final chiIndex = dayCanChi.chi;
    
    // Good directions (simplified rules)
    // These are example calculations - real rules are more complex
    final goodDirections = _calculateGoodDirections(canIndex, chiIndex);
    final badDirections = _calculateBadDirections(canIndex, chiIndex);
    
    directions.addAll(goodDirections);
    directions.addAll(badDirections);
    
    return directions;
  }
  
  /// Calculate good directions based on Can Chi
  static List<TravelDirection> _calculateGoodDirections(int can, int chi) {
    final directions = <TravelDirection>[];
    
    // Simplified rules - in reality, these depend on complex astrological calculations
    // Example: Based on Can Chi combination, determine good directions
    
    // Tây Nam - Hỷ Thần (Joy Deity)
    // Rule: Appears on certain Can Chi combinations
    if ((can + chi) % 3 == 0) {
      directions.add(TravelDirection(
        direction: 'Tây Nam',
        type: 'good',
        deity: 'Hỷ Thần',
        description: 'Xuất hành hướng Tây Nam để đón Hỷ Thần',
      ));
    }
    
    // Chính Đông - Tài Thần (Wealth Deity)
    // Rule: Appears on certain Can Chi combinations
    if ((can + chi) % 4 == 1) {
      directions.add(TravelDirection(
        direction: 'Chính Đông',
        type: 'good',
        deity: 'Tài Thần',
        description: 'Xuất hành hướng Chính Đông để đón Tài Thần',
      ));
    }
    
    // Bắc - Quý Nhân (Noble Person)
    if ((can + chi) % 5 == 2) {
      directions.add(TravelDirection(
        direction: 'Bắc',
        type: 'good',
        deity: 'Quý Nhân',
        description: 'Xuất hành hướng Bắc để gặp Quý Nhân',
      ));
    }
    
    return directions;
  }
  
  /// Calculate bad directions based on Can Chi
  static List<TravelDirection> _calculateBadDirections(int can, int chi) {
    final directions = <TravelDirection>[];
    
    // Chính Nam - Hạc Thần (Crane Deity - bad)
    // Rule: Appears on certain Can Chi combinations
    if ((can + chi) % 3 == 1) {
      directions.add(TravelDirection(
        direction: 'Chính Nam',
        type: 'bad',
        deity: 'Hạc Thần',
        description: 'Tránh xuất hành hướng Chính Nam gặp Hạc Thần (xấu)',
      ));
    }
    
    // Tây - Sát Thần (Killing Deity)
    if ((can + chi) % 4 == 2) {
      directions.add(TravelDirection(
        direction: 'Tây',
        type: 'bad',
        deity: 'Sát Thần',
        description: 'Tránh xuất hành hướng Tây gặp Sát Thần',
      ));
    }
    
    return directions;
  }
  
  /// Get primary good direction (most auspicious)
  static TravelDirection? getPrimaryGoodDirection(SolarDate solarDate) {
    final directions = getDirectionsForDate(solarDate);
    final goodDirections = directions.where((d) => d.type == 'good').toList();
    return goodDirections.isNotEmpty ? goodDirections.first : null;
  }
  
  /// Get primary bad direction (most inauspicious)
  static TravelDirection? getPrimaryBadDirection(SolarDate solarDate) {
    final directions = getDirectionsForDate(solarDate);
    final badDirections = directions.where((d) => d.type == 'bad').toList();
    return badDirections.isNotEmpty ? badDirections.first : null;
  }
}

