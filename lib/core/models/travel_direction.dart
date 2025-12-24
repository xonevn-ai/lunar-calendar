/// Travel Direction Model
/// Represents auspicious and inauspicious directions for travel
class TravelDirection {
  final String direction; // Tây Nam, Chính Đông, Chính Nam, etc.
  final String type; // 'good' or 'bad'
  final String deity; // Hỷ Thần, Tài Thần, Hạc Thần, etc.
  final String description; // Description of the direction

  TravelDirection({
    required this.direction,
    required this.type,
    required this.deity,
    required this.description,
  });
}

