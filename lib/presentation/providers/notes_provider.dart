import 'package:flutter/foundation.dart';
import '../../core/models/note.dart';
import '../../core/models/calendar_date.dart';
import '../../data/repositories/notes_repository.dart';
import 'package:uuid/uuid.dart';

/// Notes Provider for state management
class NotesProvider extends ChangeNotifier {
  final NotesRepository _repository = NotesRepository();
  final Uuid _uuid = const Uuid();

  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  String? _searchQuery;
  String? _selectedTag;

  List<Note> get allNotes => _allNotes;
  List<Note> get filteredNotes => _filteredNotes;
  String? get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;

  NotesProvider() {
    _loadNotes();
  }

  /// Load all notes
  void _loadNotes() {
    _allNotes = _repository.getAllNotes();
    _applyFilters();
    notifyListeners();
  }

  /// Apply filters (search and tag)
  void _applyFilters() {
    _filteredNotes = _allNotes;

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredNotes = _repository.searchNotes(_searchQuery!);
    } else if (_selectedTag != null) {
      _filteredNotes = _repository.getNotesByTag(_selectedTag!);
    }
  }

  /// Get notes for a specific date
  List<Note> getNotesForDate(SolarDate solarDate) {
    return _repository.getNotesForDate(solarDate);
  }

  /// Get notes count for a date
  int getNotesCountForDate(SolarDate solarDate) {
    return _repository.getNotesCountForDate(solarDate);
  }

  /// Get all tags
  List<String> getAllTags() {
    return _repository.getAllTags();
  }

  /// Create a new note
  Future<void> createNote({
    required SolarDate solarDate,
    required String title,
    required String content,
    List<String> tags = const [],
    String? color,
  }) async {
    final note = Note.fromSolarDate(
      id: _uuid.v4(),
      solarDate: solarDate,
      title: title,
      content: content,
      tags: tags,
      color: color,
    );

    await _repository.saveNote(note);
    _loadNotes();
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _repository.saveNote(updatedNote);
    _loadNotes();
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    _loadNotes();
  }

  /// Delete notes for a specific date
  Future<void> deleteNotesForDate(SolarDate solarDate) async {
    await _repository.deleteNotesForDate(solarDate);
    _loadNotes();
  }

  /// Search notes
  void searchNotes(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _selectedTag = null; // Clear tag filter when searching
    _applyFilters();
    notifyListeners();
  }

  /// Filter by tag
  void filterByTag(String? tag) {
    _selectedTag = tag;
    _searchQuery = null; // Clear search when filtering by tag
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _selectedTag = null;
    _applyFilters();
    notifyListeners();
  }

  /// Get note by ID
  Note? getNoteById(String id) {
    return _repository.getNoteById(id);
  }
}

