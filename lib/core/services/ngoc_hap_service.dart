import '../models/calendar_date.dart';
import '../models/ngoc_hap.dart';
import '../canchi/canchi_calculator.dart';
import '../lunar/lunar_calculator.dart';

/// Ngọc Hạp Thông Thư Service
/// Provides good and bad stars for the day
class NgocHapService {
  /// Get good stars for a date
  static List<NgocHapSao> getGoodStarsForDate(SolarDate date) {
    final stars = <NgocHapSao>[];
    final dayCanChi = getDayCanChi(date);
    
    // Simplified calculation - actual rules are more complex
    // Based on Can Chi, lunar day, and other factors
    
    // Thiên Phú - appears on certain days
    if (_hasThienPhu(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Thiên Phú',
        chineseName: '天富',
        type: NgocHapSaoType.good,
        affects: ['Khai trương', 'Xây dựng nhà cửa', 'An táng', 'Mọi việc'],
        description: 'Tốt cho mọi việc, nhất là khai trương, việc xây dựng nhà cửa và an táng',
      ));
    }
    
    // Thiên Phúc
    if (_hasThienPhuc(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Thiên Phúc',
        chineseName: '天福',
        type: NgocHapSaoType.good,
        affects: ['Mọi việc'],
        description: 'Tốt cho mọi việc',
      ));
    }
    
    // Thiên Mã (Lộc Mã)
    if (_hasThienMa(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Thiên Mã',
        chineseName: '天馬',
        type: NgocHapSaoType.good,
        affects: ['Giao dịch', 'Cầu tài lộc', 'Kinh doanh', 'Xuất hành'],
        description: 'Tốt cho việc giao dịch, cầu tài lộc, kinh doanh, xuất hành',
      ));
    }
    
    // Nguyệt Không
    if (_hasNguyetKhong(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Nguyệt Không',
        chineseName: '月空',
        type: NgocHapSaoType.good,
        affects: ['Làm nhà', 'Sửa nhà', 'Làm giường', 'Đặt giường'],
        description: 'Tốt cho việc làm nhà, sửa nhà, làm giường, đặt giường',
      ));
    }
    
    // Lộc Khố
    if (_hasLocKho(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Lộc Khố',
        chineseName: '祿庫',
        type: NgocHapSaoType.good,
        affects: ['Khai trương', 'Kinh doanh', 'Cầu tài', 'Giao dịch'],
        description: 'Tốt cho việc khai trương, kinh doanh, cầu tài, giao dịch',
      ));
    }
    
    // Phúc Sinh
    if (_hasPhucSinh(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Phúc Sinh',
        chineseName: '福生',
        type: NgocHapSaoType.good,
        affects: ['Mọi việc'],
        description: 'Tốt cho mọi việc',
      ));
    }
    
    // Dịch Mã
    if (_hasDichMa(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Dịch Mã',
        chineseName: '驛馬',
        type: NgocHapSaoType.good,
        affects: ['Mọi việc', 'Xuất hành'],
        description: 'Tốt cho mọi việc, nhất là việc xuất hành',
      ));
    }
    
    return stars;
  }
  
  /// Get bad stars for a date
  static List<NgocHapSao> getBadStarsForDate(SolarDate date) {
    final stars = <NgocHapSao>[];
    final dayCanChi = getDayCanChi(date);
    
    // Thổ Ôn (Thiên Cẩu)
    if (_hasThoOn(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Thổ Ôn',
        chineseName: '土瘟',
        type: NgocHapSaoType.bad,
        affects: ['Xây dựng', 'Đào ao', 'Đào giếng', 'Tế tự (cúng bái)'],
        description: 'Kỵ việc xây dựng, đào ao, đào giếng, xấu về tế tự (cúng bái)',
      ));
    }
    
    // Hoang Vu
    if (_hasHoangVu(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Hoang Vu',
        chineseName: '荒蕪',
        type: NgocHapSaoType.bad,
        affects: ['Mọi công việc'],
        description: 'Xấu cho mọi công việc',
      ));
    }
    
    // Hoàng Sa
    if (_hasHoangSa(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Hoàng Sa',
        chineseName: '黃沙',
        type: NgocHapSaoType.bad,
        affects: ['Xuất hành'],
        description: 'Xấu đối với việc xuất hành',
      ));
    }
    
    // Bạch Hổ Hắc Đạo
    if (_hasBachHoHacDao(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Bạch Hổ Hắc Đạo',
        chineseName: '白虎黑道',
        type: NgocHapSaoType.bad,
        affects: ['Mai táng'],
        description: 'Kỵ việc mai táng. Nếu trùng ngày với Thiên Giải thì sao tốt',
        exception: 'Nếu trùng ngày với Thiên Giải thì sao tốt',
      ));
    }
    
    // Quả Tú
    if (_hasQuaTu(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Quả Tú',
        chineseName: '寡宿',
        type: NgocHapSaoType.bad,
        affects: ['Giá thú (cưới hỏi)'],
        description: 'Xấu với việc giá thú (cưới hỏi)',
      ));
    }
    
    // Sát Chủ
    if (_hasSatChu(date, dayCanChi)) {
      stars.add(NgocHapSao(
        name: 'Sát Chủ',
        chineseName: '殺主',
        type: NgocHapSaoType.bad,
        affects: ['Mọi công việc'],
        description: 'Xấu cho mọi công việc',
      ));
    }
    
    return stars;
  }
  
  // Helper methods to check for specific stars
  // These are simplified - actual calculations are more complex
  
  static bool _hasThienPhu(SolarDate date, dynamic dayCanChi) {
    // Simplified: Check based on Can Chi patterns
    return dayCanChi.chiName == 'Mùi' || dayCanChi.chiName == 'Tuất';
  }
  
  static bool _hasThienPhuc(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.canName == 'Giáp' || dayCanChi.canName == 'Ất';
  }
  
  static bool _hasThienMa(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.chiName == 'Thân' || dayCanChi.chiName == 'Tý';
  }
  
  static bool _hasNguyetKhong(SolarDate date, dynamic dayCanChi) {
    final lunar = solarToLunar(date);
    return lunar.day == 1 || lunar.day == 15;
  }
  
  static bool _hasLocKho(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.canName == 'Mậu' || dayCanChi.canName == 'Kỷ';
  }
  
  static bool _hasPhucSinh(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.canName == 'Bính' || dayCanChi.canName == 'Đinh';
  }
  
  static bool _hasDichMa(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.chiName == 'Dần' || dayCanChi.chiName == 'Ngọ';
  }
  
  static bool _hasThoOn(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.element.name == 'Thổ' && 
           (dayCanChi.chiName == 'Thìn' || dayCanChi.chiName == 'Tuất');
  }
  
  static bool _hasHoangVu(SolarDate date, dynamic dayCanChi) {
    final lunar = solarToLunar(date);
    return lunar.day == 4 || lunar.day == 10 || lunar.day == 16 || lunar.day == 22 || lunar.day == 28;
  }
  
  static bool _hasHoangSa(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.chiName == 'Mão' || dayCanChi.chiName == 'Dậu';
  }
  
  static bool _hasBachHoHacDao(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.chiName == 'Dần' || dayCanChi.chiName == 'Thân';
  }
  
  static bool _hasQuaTu(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.chiName == 'Sửu' || dayCanChi.chiName == 'Mùi';
  }
  
  static bool _hasSatChu(SolarDate date, dynamic dayCanChi) {
    return dayCanChi.canName == 'Canh' || dayCanChi.canName == 'Tân';
  }
}

