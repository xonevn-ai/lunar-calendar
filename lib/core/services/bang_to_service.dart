import '../models/calendar_date.dart';
import '../models/bang_to.dart';
import '../canchi/canchi_calculator.dart';
import '../constants.dart';

/// Bành Tổ Bách Kỵ Nhật Service
/// Provides traditional prohibitions based on Can Chi
class BangToService {
  /// Get Bành Tổ prohibition for Can (Thiên Can)
  static BangTo? getProhibitionForCan(String can) {
    final data = bangToCan[can];
    if (data == null) return null;
    
    return BangTo(
      can: can,
      prohibition: data['prohibition'],
      vietnameseProhibition: data['vietnamese'],
      description: data['description'],
      avoidActivities: List<String>.from(data['avoidActivities']),
    );
  }
  
  /// Get Bành Tổ prohibition for Chi (Địa Chi)
  static BangToChi? getProhibitionForChi(String chi) {
    final data = bangToChi[chi];
    if (data == null) return null;
    
    return BangToChi(
      chi: chi,
      prohibition: data['prohibition'],
      vietnameseProhibition: data['vietnamese'],
      description: data['description'],
      avoidActivities: List<String>.from(data['avoidActivities']),
    );
  }
  
  /// Get Bành Tổ prohibitions for a date
  /// Returns both Can and Chi prohibitions
  static Map<String, dynamic> getProhibitionsForDate(SolarDate date) {
    final dayCanChi = getDayCanChi(date);
    final canProhibition = getProhibitionForCan(dayCanChi.canName);
    final chiProhibition = getProhibitionForChi(dayCanChi.chiName);
    
    return {
      'can': canProhibition,
      'chi': chiProhibition,
      'dayCanChi': dayCanChi,
    };
  }
  
  /// Get all prohibitions as a list
  static List<Map<String, dynamic>> getAllProhibitionsForDate(SolarDate date) {
    final prohibitions = <Map<String, dynamic>>[];
    final dayCanChi = getDayCanChi(date);
    
    final canProhibition = getProhibitionForCan(dayCanChi.canName);
    if (canProhibition != null) {
      prohibitions.add({
        'type': 'Can',
        'name': dayCanChi.canName,
        'prohibition': canProhibition,
      });
    }
    
    final chiProhibition = getProhibitionForChi(dayCanChi.chiName);
    if (chiProhibition != null) {
      prohibitions.add({
        'type': 'Chi',
        'name': dayCanChi.chiName,
        'prohibition': chiProhibition,
      });
    }
    
    return prohibitions;
  }
}

