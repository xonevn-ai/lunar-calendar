import 'hour_info.dart';

/// Travel Hour Model
/// Represents hour-by-hour travel guidance according to Lý Thuần Phong
class TravelHour {
  final HourInfo hour;
  final String description;
  final bool isGood;
  final String? direction; // Optional direction for this hour
  final List<String> activities; // Activities suitable/unsuitable for this hour
  final String? warning; // Warning message if any

  TravelHour({
    required this.hour,
    required this.description,
    required this.isGood,
    this.direction,
    required this.activities,
    this.warning,
  });
}

