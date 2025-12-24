import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/note.dart';
import '../../core/models/calendar_date.dart';
import '../local/hive_storage.dart';

/// Notes Repository
/// Handles CRUD operations for notes
class NotesRepository {
  Box<Note> get _notesBox => HiveStorage.getNotesBox();

  /// Get all notes
  List<Note> getAllNotes() {
    return _notesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get notes for a specific date
  List<Note> getNotesForDate(SolarDate solarDate) {
    final date = DateTime(solarDate.year, solarDate.month, solarDate.day);
    return _notesBox.values
        .where((note) =>
            note.date.year == date.year &&
            note.date.month == date.month &&
            note.date.day == date.day)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get notes for a date range
  List<Note> getNotesForDateRange(DateTime start, DateTime end) {
    return _notesBox.values
        .where((note) =>
            note.date.isAfter(start.subtract(const Duration(days: 1))) &&
            note.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get note by ID
  Note? getNoteById(String id) {
    return _notesBox.get(id);
  }

  /// Save note (create or update)
  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  /// Delete note
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  /// Delete notes for a specific date
  Future<void> deleteNotesForDate(SolarDate solarDate) async {
    final notes = getNotesForDate(solarDate);
    for (final note in notes) {
      await deleteNote(note.id);
    }
  }

  /// Search notes by title or content
  List<Note> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _notesBox.values
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) ||
            note.content.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _notesBox.values
        .where((note) => note.tags.contains(tag))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get all unique tags
  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _notesBox.values) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  /// Get notes count
  int getNotesCount() {
    return _notesBox.length;
  }

  /// Get notes count for a date
  int getNotesCountForDate(SolarDate solarDate) {
    return getNotesForDate(solarDate).length;
  }
}

