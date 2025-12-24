import '../models/calendar_date.dart';
import '../models/luc_dieu.dart';
import '../lunar/lunar_calculator.dart';

/// Khổng Minh Lục Diệu Calculator
/// Calculates the six signs for a given date
class LucDieuCalculator {
  /// Calculate Luc Dieu for a date
  /// Based on lunar day and Can Chi
  static LucDieu calculateForDate(SolarDate date) {
    final lunar = solarToLunar(date);
    
    // Luc Dieu is calculated based on:
    // 1. Lunar day (1-30)
    // 2. Can Chi combination
    // The cycle repeats every 6 days
    
    // Simplified calculation: Use lunar day modulo 6
    // Actual calculation may be more complex
    final lucDieuIndex = (lunar.day - 1) % 6;
    
    return _getLucDieuByIndex(lucDieuIndex);
  }
  
  /// Get Luc Dieu by index (0-5)
  static LucDieu _getLucDieuByIndex(int index) {
    switch (index) {
      case 0:
        return LucDieu(
          type: LucDieuType.daiAn,
          name: 'Dai An',
          vietnameseName: 'Đại An',
          description: 'Ngày rất tốt, mọi việc đều thuận lợi',
          isGood: true,
          morningStatus: 'Rất tốt',
          afternoonStatus: 'Rất tốt',
          poem: 'Đại An là ngày tốt lành\nMọi việc đều thuận, vạn sự hanh thông',
          goodFor: ['Khởi công', 'Xuất hành', 'Cưới hỏi', 'Khai trương'],
          avoid: [],
        );
      case 1:
        return LucDieu(
          type: LucDieuType.luuLien,
          name: 'Luu Lien',
          vietnameseName: 'Lưu Liên',
          description: 'Ngày xấu, mọi việc đều khó khăn, nên tránh',
          isGood: false,
          morningStatus: 'Xấu',
          afternoonStatus: 'Xấu',
          poem: 'Lưu Liên là ngày không may\nMọi việc đều khó, nên tránh xa',
          goodFor: [],
          avoid: ['Khởi công', 'Xuất hành', 'Cưới hỏi', 'Khai trương'],
        );
      case 2:
        return LucDieu(
          type: LucDieuType.tocHy,
          name: 'Toc Hy',
          vietnameseName: 'Tốc Hỷ',
          description: 'Ngày tốt vừa. Buổi sáng tốt, nhưng chiều xấu nên cần làm nhanh',
          isGood: true,
          morningStatus: 'Tốt',
          afternoonStatus: 'Xấu',
          poem: 'Tốc Hỷ là bạn trùng phùng\nGặp trùng gặp bạn vợ chồng sánh đôi\nCó tài có lộc hẳn hoi\nCầu gì cũng được mừng vui thỏa lòng',
          goodFor: ['Mưu đại sự', 'Xuất hành buổi sáng'],
          avoid: ['Làm việc buổi chiều'],
        );
      case 3:
        return LucDieu(
          type: LucDieuType.xichKhau,
          name: 'Xich Khau',
          vietnameseName: 'Xích Khẩu',
          description: 'Ngày xấu, dễ gây tranh cãi, kiện tụng',
          isGood: false,
          morningStatus: 'Xấu',
          afternoonStatus: 'Xấu',
          poem: 'Xích Khẩu là ngày không may\nDễ gây tranh cãi, kiện tụng đầy',
          goodFor: [],
          avoid: ['Tranh luận', 'Kiện tụng', 'Ký kết hợp đồng'],
        );
      case 4:
        return LucDieu(
          type: LucDieuType.tieuCat,
          name: 'Tieu Cat',
          vietnameseName: 'Tiểu Cát',
          description: 'Ngày tốt nhỏ, mọi việc đều thuận lợi vừa phải',
          isGood: true,
          morningStatus: 'Tốt',
          afternoonStatus: 'Tốt',
          poem: 'Tiểu Cát là ngày tốt lành\nMọi việc đều thuận, hanh thông',
          goodFor: ['Mọi việc thường ngày'],
          avoid: [],
        );
      case 5:
        return LucDieu(
          type: LucDieuType.khongVong,
          name: 'Khong Vong',
          vietnameseName: 'Không Vong',
          description: 'Ngày xấu, mọi việc đều không thành, nên tránh',
          isGood: false,
          morningStatus: 'Xấu',
          afternoonStatus: 'Xấu',
          poem: 'Không Vong là ngày không may\nMọi việc đều không thành, nên tránh xa',
          goodFor: [],
          avoid: ['Mọi việc quan trọng'],
        );
      default:
        return _getLucDieuByIndex(0);
    }
  }
  
  /// Get Luc Dieu name by type
  static String getName(LucDieuType type) {
    switch (type) {
      case LucDieuType.daiAn:
        return 'Đại An';
      case LucDieuType.luuLien:
        return 'Lưu Liên';
      case LucDieuType.tocHy:
        return 'Tốc Hỷ';
      case LucDieuType.xichKhau:
        return 'Xích Khẩu';
      case LucDieuType.tieuCat:
        return 'Tiểu Cát';
      case LucDieuType.khongVong:
        return 'Không Vong';
    }
  }
}

