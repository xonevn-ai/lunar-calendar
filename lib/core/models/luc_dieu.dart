/// Khổng Minh Lục Diệu (Kongming Six Signs) Model
/// Six auspicious/inauspicious day types
enum LucDieuType {
  tocHy,      // Tốc Hỷ - Quick Joy
  xichKhau,   // Xích Khẩu - Red Mouth
  tieuCat,    // Tiểu Cát - Small Auspicious
  khongVong,  // Không Vong - Empty Void
  daiAn,      // Đại An - Great Peace
  luuLien,    // Lưu Liên - Lingering
}

/// Luc Dieu (Six Signs) information
class LucDieu {
  final LucDieuType type;
  final String name;
  final String vietnameseName;
  final String description;
  final bool isGood;
  final String morningStatus; // Morning fortune
  final String afternoonStatus; // Afternoon fortune
  final String poem; // Traditional poem
  final List<String> goodFor; // Good for activities
  final List<String> avoid; // Avoid activities
  
  LucDieu({
    required this.type,
    required this.name,
    required this.vietnameseName,
    required this.description,
    required this.isGood,
    required this.morningStatus,
    required this.afternoonStatus,
    this.poem = '',
    this.goodFor = const [],
    this.avoid = const [],
  });
  
  /// Get display name
  String get displayName => vietnameseName.isNotEmpty ? vietnameseName : name;
}

