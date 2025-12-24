/// Bành Tổ Bách Kỵ Nhật Model
/// Traditional prohibitions based on Can Chi combinations
class BangTo {
  final String can; // Thiên Can (Giáp, Ất, Bính, etc.)
  final String prohibition; // Traditional prohibition text
  final String vietnameseProhibition; // Vietnamese translation
  final String description; // Detailed description
  final List<String> avoidActivities; // Specific activities to avoid
  
  BangTo({
    required this.can,
    required this.prohibition,
    required this.vietnameseProhibition,
    required this.description,
    required this.avoidActivities,
  });
}

/// Bành Tổ for Chi (Địa Chi)
class BangToChi {
  final String chi; // Địa Chi (Tý, Sửu, Dần, etc.)
  final String prohibition; // Traditional prohibition text
  final String vietnameseProhibition; // Vietnamese translation
  final String description; // Detailed description
  final List<String> avoidActivities; // Specific activities to avoid
  
  BangToChi({
    required this.chi,
    required this.prohibition,
    required this.vietnameseProhibition,
    required this.description,
    required this.avoidActivities,
  });
}

