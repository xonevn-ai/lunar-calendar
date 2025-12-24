import 'package:hive/hive.dart';

part 'quote.g.dart';

/// Quote model for storing Vietnamese quotes
@HiveType(typeId: 1)
class Quote extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final String? author;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final bool isCustom; // User-added quotes
  
  Quote({
    required this.id,
    required this.text,
    this.author,
    DateTime? createdAt,
    this.isCustom = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Create a copy with updated fields
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    DateTime? createdAt,
    bool? isCustom,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

