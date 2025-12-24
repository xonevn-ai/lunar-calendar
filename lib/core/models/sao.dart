/// Nhị Thập Bát Tú (28 Stars) Model
/// Represents one of the 28 constellations/stars
class Sao {
  final int index; // 1-28
  final String name; // Vietnamese name
  final String chineseName; // Chinese name
  final String element; // Kim, Mộc, Thủy, Hỏa, Thổ
  final bool isGood; // Good or bad star
  final String animal; // Associated animal
  final String dayName; // Day name (e.g., "Thất Hỏa Trư")
  final int dayOrder; // Day order (1-7, representing day of week)
  final List<String> goodFor; // Activities good for
  final List<String> avoid; // Activities to avoid
  final String poem; // Traditional poem
  final String? exception; // Exception conditions
  final String? phucDoanSat; // Phục Đoạn Sát condition
  
  Sao({
    required this.index,
    required this.name,
    required this.chineseName,
    required this.element,
    required this.isGood,
    required this.animal,
    required this.dayName,
    required this.dayOrder,
    required this.goodFor,
    required this.avoid,
    required this.poem,
    this.exception,
    this.phucDoanSat,
  });
  
  /// Get display name
  String get displayName => '$name ($chineseName)';
  
  /// Get full description
  String get fullDescription => '$dayName - $animal: ${element} tinh, ${isGood ? "sao tốt" : "sao xấu"}';
}

