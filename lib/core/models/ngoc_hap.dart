/// Ngọc Hạp Thông Thư Model
/// Good and bad stars for the day
enum NgocHapSaoType {
  good, // Sao tốt
  bad,  // Sao xấu
}

/// Ngọc Hạp Sao (Star)
class NgocHapSao {
  final String name;
  final String chineseName;
  final NgocHapSaoType type;
  final List<String> affects; // What it affects
  final String? exception; // Exception conditions
  final String description; // Detailed description
  
  NgocHapSao({
    required this.name,
    required this.chineseName,
    required this.type,
    required this.affects,
    this.exception,
    required this.description,
  });
  
  /// Get display name
  String get displayName => '$name ($chineseName)';
  
  /// Is good star
  bool get isGood => type == NgocHapSaoType.good;
}

