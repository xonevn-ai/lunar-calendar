import 'package:flutter/foundation.dart';

/// Calendar Provider for state management
class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  void goToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _focusedDate = today;
    notifyListeners();
  }

  void goToPreviousMonth() {
    _focusedDate = DateTime(
      _focusedDate.year,
      _focusedDate.month - 1,
      1,
    );
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedDate = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      1,
    );
    notifyListeners();
  }
}

