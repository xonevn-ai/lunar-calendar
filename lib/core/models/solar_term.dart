import 'calendar_date.dart';

/// Solar Term (Tiết Khí) - 24 solar terms in a year
class SolarTerm {
  final int index;
  final String name;
  final String chineseName;
  final SolarDate date;
  final String description;

  const SolarTerm({
    required this.index,
    required this.name,
    required this.chineseName,
    required this.date,
    required this.description,
  });

  @override
  String toString() => '$name (${date.day}/${date.month}/${date.year})';
}

