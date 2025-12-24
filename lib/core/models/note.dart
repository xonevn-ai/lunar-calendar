import 'package:hive/hive.dart';
import 'calendar_date.dart';

part 'note.g.dart';

/// Note model for storing user notes
@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final String? color;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.tags = const [],
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create Note from SolarDate
  factory Note.fromSolarDate({
    required String id,
    required SolarDate solarDate,
    required String title,
    required String content,
    List<String> tags = const [],
    String? color,
  }) {
    final date = DateTime(solarDate.year, solarDate.month, solarDate.day);
    return Note(
      id: id,
      date: date,
      title: title,
      content: content,
      tags: tags,
      color: color,
    );
  }

  /// Convert to SolarDate
  SolarDate toSolarDate() {
    return SolarDate(
      year: date.year,
      month: date.month,
      day: date.day,
    );
  }

  /// Create a copy with updated fields
  Note copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    List<String>? tags,
    String? color,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'Note(id: $id, date: $date, title: $title)';
}

