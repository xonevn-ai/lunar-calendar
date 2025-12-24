import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/quote.dart';
import '../../data/local/hive_storage.dart';

/// Backup data structure
class BackupData {
  final String version;
  final DateTime backupDate;
  final Map<String, dynamic> settings;
  final List<Map<String, dynamic>> notes;
  final List<Map<String, dynamic>> quotes;

  BackupData({
    required this.version,
    required this.backupDate,
    required this.settings,
    required this.notes,
    required this.quotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'backupDate': backupDate.toIso8601String(),
      'settings': settings,
      'notes': notes,
      'quotes': quotes,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] as String,
      backupDate: DateTime.parse(json['backupDate'] as String),
      settings: json['settings'] as Map<String, dynamic>,
      notes: (json['notes'] as List).cast<Map<String, dynamic>>(),
      quotes: (json['quotes'] as List).cast<Map<String, dynamic>>(),
    );
  }
}

/// Backup Service for exporting and importing app data
class BackupService {
  static const String backupVersion = '1.0.0';

  /// Export all data to JSON
  Future<BackupData> exportData() async {
    // Export settings
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, dynamic>{
      'themeMode': prefs.getInt('theme_mode') ?? 0,
      'selectedTheme': prefs.getString('selected_theme') ?? 'default',
      'notificationsEnabled': prefs.getBool('notifications_enabled') ?? true,
      'cloudSyncEnabled': prefs.getBool('cloud_sync_enabled') ?? false,
      'weekStart': prefs.getInt('week_start') ?? 1,
      'defaultView': prefs.getString('default_view') ?? 'month',
      'reminderTimeHour': prefs.getInt('reminder_time_hour') ?? 8,
      'reminderTimeMinute': prefs.getInt('reminder_time_minute') ?? 0,
    };

    // Export notes
    final notesBox = HiveStorage.getNotesBox();
    final notes = notesBox.values.map((note) => {
          'id': note.id,
          'date': note.date.toIso8601String(),
          'title': note.title,
          'content': note.content,
          'tags': note.tags,
          'color': note.color,
          'createdAt': note.createdAt.toIso8601String(),
          'updatedAt': note.updatedAt.toIso8601String(),
        }).toList();

    // Export quotes
    final quotesBox = await Hive.openBox<Quote>('quotes');
    final quotes = quotesBox.values.map((quote) => {
          'id': quote.id,
          'text': quote.text,
          'author': quote.author,
          'createdAt': quote.createdAt.toIso8601String(),
          'isCustom': quote.isCustom,
        }).toList();

    return BackupData(
      version: backupVersion,
      backupDate: DateTime.now(),
      settings: settings,
      notes: notes,
      quotes: quotes,
    );
  }

  /// Save backup to file
  Future<File> saveBackupToFile(BackupData backupData) async {
    if (kIsWeb) {
      // On web, we can't use File directly, return a placeholder
      // The actual download will be handled in the UI layer
      throw UnsupportedError('File saving not supported on web. Use downloadBackupForWeb instead.');
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final file = File('${directory.path}/lunar_calendar_backup_$timestamp.json');

    final jsonString = jsonEncode(backupData.toJson());
    await file.writeAsString(jsonString);

    return file;
  }

  /// Get backup as JSON string for web download
  Future<String> downloadBackupForWeb() async {
    final backupData = await exportData();
    return jsonEncode(backupData.toJson());
  }

  /// Export backup and return file path
  Future<File> exportBackup() async {
    final backupData = await exportData();
    return await saveBackupToFile(backupData);
  }

  /// Import data from JSON
  Future<void> importData(BackupData backupData, {bool replaceExisting = false}) async {
    // Import settings
    final prefs = await SharedPreferences.getInstance();
    if (backupData.settings.containsKey('themeMode')) {
      await prefs.setInt('theme_mode', backupData.settings['themeMode'] as int);
    }
    if (backupData.settings.containsKey('selectedTheme')) {
      await prefs.setString('selected_theme', backupData.settings['selectedTheme'] as String);
    }
    if (backupData.settings.containsKey('notificationsEnabled')) {
      await prefs.setBool('notifications_enabled', backupData.settings['notificationsEnabled'] as bool);
    }
    if (backupData.settings.containsKey('cloudSyncEnabled')) {
      await prefs.setBool('cloud_sync_enabled', backupData.settings['cloudSyncEnabled'] as bool);
    }
    if (backupData.settings.containsKey('weekStart')) {
      await prefs.setInt('week_start', backupData.settings['weekStart'] as int);
    }
    if (backupData.settings.containsKey('defaultView')) {
      await prefs.setString('default_view', backupData.settings['defaultView'] as String);
    }
    if (backupData.settings.containsKey('reminderTimeHour')) {
      await prefs.setInt('reminder_time_hour', backupData.settings['reminderTimeHour'] as int);
    }
    if (backupData.settings.containsKey('reminderTimeMinute')) {
      await prefs.setInt('reminder_time_minute', backupData.settings['reminderTimeMinute'] as int);
    }

    // Import notes
    final notesBox = HiveStorage.getNotesBox();
    if (replaceExisting) {
      await notesBox.clear();
    }

    for (final noteData in backupData.notes) {
      final note = Note(
        id: noteData['id'] as String,
        date: DateTime.parse(noteData['date'] as String),
        title: noteData['title'] as String,
        content: noteData['content'] as String,
        tags: (noteData['tags'] as List).cast<String>(),
        color: noteData['color'] as String?,
        createdAt: DateTime.parse(noteData['createdAt'] as String),
        updatedAt: DateTime.parse(noteData['updatedAt'] as String),
      );
      await notesBox.put(note.id, note);
    }

    // Import quotes
    final quotesBox = await Hive.openBox<Quote>('quotes');
    if (replaceExisting) {
      await quotesBox.clear();
    }

    for (final quoteData in backupData.quotes) {
      final quote = Quote(
        id: quoteData['id'] as String,
        text: quoteData['text'] as String,
        author: quoteData['author'] as String?,
        createdAt: DateTime.parse(quoteData['createdAt'] as String),
        isCustom: quoteData['isCustom'] as bool? ?? false,
      );
      await quotesBox.put(quote.id, quote);
    }
  }

  /// Import backup from file
  Future<void> importBackupFromFile(File file, {bool replaceExisting = false}) async {
    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final backupData = BackupData.fromJson(json);
      await importData(backupData, replaceExisting: replaceExisting);
    } catch (e) {
      throw Exception('Lỗi khi đọc file backup: $e');
    }
  }

  /// Import backup from JSON string
  Future<void> importBackupFromJson(String jsonString, {bool replaceExisting = false}) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final backupData = BackupData.fromJson(json);
      await importData(backupData, replaceExisting: replaceExisting);
    } catch (e) {
      throw Exception('Lỗi khi đọc dữ liệu backup: $e');
    }
  }

  /// Validate backup file
  Future<bool> validateBackupFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Check required fields
      if (!json.containsKey('version') ||
          !json.containsKey('backupDate') ||
          !json.containsKey('settings') ||
          !json.containsKey('notes') ||
          !json.containsKey('quotes')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get backup file info
  Future<Map<String, dynamic>?> getBackupInfo(File file) async {
    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return {
        'version': json['version'],
        'backupDate': json['backupDate'],
        'notesCount': (json['notes'] as List).length,
        'quotesCount': (json['quotes'] as List).length,
      };
    } catch (e) {
      return null;
    }
  }
}

