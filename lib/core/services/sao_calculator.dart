import '../models/calendar_date.dart';
import '../models/sao.dart';
import '../lunar/lunar_calculator.dart';

/// Nhị Thập Bát Tú (28 Stars) Calculator
/// Calculates which star (1-28) is active for a given date
class SaoCalculator {
  /// Get Sao for a specific date
  /// Based on lunar month and day
  static Sao getSaoForDate(SolarDate date) {
    final lunar = solarToLunar(date);
    
    // 28 stars cycle through the lunar month
    // Each star rules for approximately 1 day
    // The cycle starts from the beginning of each lunar month
    
    // Simplified calculation: Use lunar day modulo 28
    // Actual calculation may be more complex and depends on the year
    final saoIndex = ((lunar.month - 1) * 28 + (lunar.day - 1)) % 28;
    
    return _getSaoByIndex(saoIndex);
  }
  
  /// Get Sao by index (0-27, representing stars 1-28)
  static Sao _getSaoByIndex(int index) {
    // This is a simplified version
    // Actual 28 stars data needs to be populated with full information
    final stars = _getAllStars();
    return stars[index];
  }
  
  /// Get all 28 stars
  /// This is a partial implementation - needs full data
  static List<Sao> _getAllStars() {
    return [
      // Star 1: Giác (角)
      Sao(
        index: 1,
        name: 'Giác',
        chineseName: '角',
        element: 'Mộc',
        isGood: true,
        animal: 'Giao Long',
        dayName: 'Giác Mộc Giao',
        dayOrder: 1,
        goodFor: ['Khởi công', 'Xuất hành'],
        avoid: [],
        poem: 'Giác tinh tạo tác chủ vinh xương',
      ),
      // Star 2: Cang (亢)
      Sao(
        index: 2,
        name: 'Cang',
        chineseName: '亢',
        element: 'Kim',
        isGood: false,
        animal: 'Kim Long',
        dayName: 'Cang Kim Long',
        dayOrder: 2,
        goodFor: [],
        avoid: ['Khởi công', 'Xuất hành'],
        poem: 'Cang tinh bất khả tạo long đường',
      ),
      // Star 3: Đê (氐)
      Sao(
        index: 3,
        name: 'Đê',
        chineseName: '氐',
        element: 'Thổ',
        isGood: false,
        animal: 'Thổ Lạc',
        dayName: 'Đê Thổ Lạc',
        dayOrder: 3,
        goodFor: [],
        avoid: ['Xây dựng'],
        poem: 'Đê tinh tạo tác chủ tai ương',
      ),
      // Star 4: Phòng (房)
      Sao(
        index: 4,
        name: 'Phòng',
        chineseName: '房',
        element: 'Nhật',
        isGood: true,
        animal: 'Nhật Thố',
        dayName: 'Phòng Nhật Thố',
        dayOrder: 4,
        goodFor: ['Cưới hỏi', 'Khai trương'],
        avoid: [],
        poem: 'Phòng tinh tạo tác điền viên vượng',
      ),
      // Star 5: Tâm (心)
      Sao(
        index: 5,
        name: 'Tâm',
        chineseName: '心',
        element: 'Nguyệt',
        isGood: false,
        animal: 'Nguyệt Hồ',
        dayName: 'Tâm Nguyệt Hồ',
        dayOrder: 5,
        goodFor: [],
        avoid: ['Cưới hỏi'],
        poem: 'Tâm tinh tạo tác đại hung vương',
      ),
      // Star 6: Vĩ (尾)
      Sao(
        index: 6,
        name: 'Vĩ',
        chineseName: '尾',
        element: 'Hỏa',
        isGood: true,
        animal: 'Hỏa Hổ',
        dayName: 'Vĩ Hỏa Hổ',
        dayOrder: 6,
        goodFor: ['Xuất hành', 'Khai trương'],
        avoid: [],
        poem: 'Vĩ tinh tạo tác đắc thiên ân',
      ),
      // Star 7: Thất (箕) - Example from data
      Sao(
        index: 7,
        name: 'Thất',
        chineseName: '箕',
        element: 'Hỏa',
        isGood: true,
        animal: 'Hỏa Trư',
        dayName: 'Thất Hỏa Trư',
        dayOrder: 3,
        goodFor: [
          'Khởi công trăm việc',
          'Tháo nước',
          'Thủy lợi',
          'Đi thuyền',
          'Xây cất nhà cửa',
          'Trổ cửa',
          'Cưới gả',
          'Chôn cất',
          'Chặt cỏ phá đất',
          'Kinh doanh',
          'Hôn nhân',
        ],
        avoid: [],
        exception: 'Sao Thất Đại Kiết tại Ngọ, Tuất và Dần nói chung đều tốt, đặc biệt ngày Ngọ Đăng viên rất hiển đạt',
        phucDoanSat: 'Ba ngày là: Bính Dần, Nhâm Dần và Giáp Ngọ tốt cho xây dựng, chôn cất, song cũng ngày Dần nhưng ngày Dần khác lại không tốt. Bởi sao Thất gặp ngày Dần là phạm vào Phục Đoạn Sát',
        poem: 'Thất tinh tạo tác tiến điền ngưu,\nNhi tôn đại đại cận quân hầu,\nPhú quý vinh hoa thiên thượng chỉ,\nThọ như Bành tổ nhập thiên thu.\nKhai môn, phóng thủy chiêu tài bạch,\nHòa hợp hôn nhân sinh quý nhi.\nMai táng nhược năng y thử nhật,\nMôn đình hưng vượng, Phúc vô ưu!',
      ),
      // Continue with remaining 21 stars...
      // For now, I'll create placeholder stars to complete the cycle
      ...List.generate(21, (i) => Sao(
        index: 8 + i,
        name: 'Sao ${8 + i}',
        chineseName: '星${8 + i}',
        element: 'Mộc',
        isGood: true,
        animal: 'Thú',
        dayName: 'Sao ${8 + i}',
        dayOrder: (i % 7) + 1,
        goodFor: ['Khởi công'],
        avoid: [],
        poem: 'Poem for star ${8 + i}',
      )),
    ];
  }
  
  /// Get Sao name by index
  static String getName(int index) {
    final sao = _getSaoByIndex((index - 1) % 28);
    return sao.displayName;
  }
}

