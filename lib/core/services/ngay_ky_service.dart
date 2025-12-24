import '../models/calendar_date.dart';
import '../models/ngay_ky.dart';
import '../models/can_chi.dart';
import '../canchi/canchi_calculator.dart';
import '../constants.dart';

/// Ngày Kỵ Service
/// Calculates days to avoid for specific activities
class NgayKyService {
  /// Get all ngày kỵ for a specific date
  static List<NgayKy> getNgayKyForDate(SolarDate date) {
    final ngayKyList = <NgayKy>[];
    final dayCanChi = getDayCanChi(date);
    
    // Check for Sát Chủ Âm
    // This is a complex calculation based on Can Chi combinations
    // Simplified version: check specific patterns
    if (_isSatChuAm(dayCanChi)) {
      ngayKyList.add(NgayKy(
        id: 'sat_chu_am',
        name: 'Sát Chủ Âm',
        vietnameseName: 'Sát Chủ Âm',
        description: 'Ngày Sát Chủ Âm là ngày kỵ các việc về mai táng, tu sửa mộ phần',
        avoidActivities: ['Mai táng', 'Tu sửa mộ phần', 'Cải táng', 'An táng'],
        calculationRule: 'Based on Can Chi combination',
      ));
    }
    
    // Add more ngày kỵ calculations as needed
    // Based on traditional rules and Can Chi patterns
    
    return ngayKyList;
  }
  
  /// Check if date is Sát Chủ Âm
  /// This is a simplified version - actual calculation may be more complex
  static bool _isSatChuAm(CanChi dayCanChi) {
    // Sát Chủ Âm typically occurs on specific Can Chi combinations
    // Example patterns (this needs to be verified with traditional sources):
    // - Certain Chi combinations with specific Can
    // - Days with conflicting elements
    
    // Simplified: Check for specific Chi that are traditionally associated
    final chiName = dayCanChi.chiName;
    
    // Some Chi are more likely to be Sát Chủ Âm
    // This is a placeholder - actual rules need traditional calendar expert input
    final satChuAmChi = ['Thân', 'Dậu', 'Tuất']; // Example
    
    return satChuAmChi.contains(chiName) && 
           dayCanChi.element.name == 'Kim'; // Example condition
  }
  
  /// Get ngày kỵ by ID
  static NgayKy? getNgayKyById(String id) {
    for (final data in ngayKyData) {
      if (data['id'] == id) {
        return NgayKy(
          id: data['id'],
          name: data['name'],
          vietnameseName: data['vietnameseName'],
          description: data['description'],
          avoidActivities: List<String>.from(data['avoidActivities']),
          calculationRule: data['calculationRule'],
        );
      }
    }
    return null;
  }
}

