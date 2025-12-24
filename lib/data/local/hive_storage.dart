import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/note.dart';
import '../../core/models/quote.dart';
import '../../core/utils/quote_service.dart';

/// Hive Storage Service
/// Manages local storage using Hive
class HiveStorage {
  static const String notesBoxName = 'notes';
  static Box<Note>? _notesBox;

  /// Initialize Hive storage
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(QuoteAdapter());
    }
    
    // Open boxes
    _notesBox = await Hive.openBox<Note>(notesBoxName);
    
    // Initialize QuoteService
    await QuoteService.init();
  }

  /// Get notes box
  static Box<Note> getNotesBox() {
    if (_notesBox == null) {
      throw Exception('HiveStorage not initialized. Call HiveStorage.init() first.');
    }
    return _notesBox!;
  }

  /// Close all boxes
  static Future<void> close() async {
    await _notesBox?.close();
  }

  /// Clear all data (for testing/debugging)
  static Future<void> clearAll() async {
    await _notesBox?.clear();
  }
}

