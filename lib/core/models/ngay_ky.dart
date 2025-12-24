/// Ngày Kỵ (Days to Avoid) Model
/// Represents days that should be avoided for specific activities
class NgayKy {
  final String id;
  final String name;
  final String vietnameseName;
  final String description;
  final List<String> avoidActivities; // Activities to avoid
  final String? calculationRule; // How this day is calculated
  
  NgayKy({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.description,
    required this.avoidActivities,
    this.calculationRule,
  });
  
  /// Get display name
  String get displayName => vietnameseName.isNotEmpty ? vietnameseName : name;
}

