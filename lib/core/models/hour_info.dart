import 'can_chi.dart';

/// Hour type: Hoàng Đạo (good) or Hắc Đạo (bad)
enum HourType {
  hoangdao,
  hacdao,
}

/// Hour information for a specific Chi
class HourInfo {
  final int chi;
  final String chiName;
  final int startHour;
  final int endHour;
  final HourType type;
  final String starName;
  final String? meaning;
  final CanChi canChi;

  const HourInfo({
    required this.chi,
    required this.chiName,
    required this.startHour,
    required this.endHour,
    required this.type,
    required this.starName,
    this.meaning,
    required this.canChi,
  });

  String get hourRange {
    final start = startHour.toString().padLeft(2, '0');
    final end = endHour.toString().padLeft(2, '0');
    return '$start:00-$end:00';
  }
}

