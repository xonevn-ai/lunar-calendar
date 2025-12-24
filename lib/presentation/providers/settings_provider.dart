import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';

/// Settings Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySelectedTheme = 'selected_theme';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyCloudSync = 'cloud_sync_enabled';
  static const String _keyWeekStart = 'week_start';
  static const String _keyDefaultView = 'default_view';
  static const String _keyReminderTime = 'reminder_time';

  ThemeMode _themeMode = ThemeMode.system;
  String _selectedTheme = 'default';
  bool _notificationsEnabled = true;
  bool _cloudSyncEnabled = false;
  int _weekStart = 1; // 1 = Monday, 0 = Sunday
  String _defaultView = 'month';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0); // Default 8:00 AM

  ThemeMode get themeMode => _themeMode;
  String get selectedTheme => _selectedTheme;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get cloudSyncEnabled => _cloudSyncEnabled;
  int get weekStart => _weekStart;
  String get defaultView => _defaultView;
  TimeOfDay get reminderTime => _reminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    _selectedTheme = prefs.getString(_keySelectedTheme) ?? 'default';
    
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _cloudSyncEnabled = prefs.getBool(_keyCloudSync) ?? false;
    _weekStart = prefs.getInt(_keyWeekStart) ?? 1;
    _defaultView = prefs.getString(_keyDefaultView) ?? 'month';
    
    // Load reminder time
    final reminderHour = prefs.getInt('${_keyReminderTime}_hour') ?? 8;
    final reminderMinute = prefs.getInt('${_keyReminderTime}_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> setSelectedTheme(String theme) async {
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTheme, theme);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
    
    // Update notification schedule
    final notificationService = NotificationService();
    if (enabled) {
      await notificationService.initialize();
      // Schedule daily reminder
      await notificationService.scheduleDailyReminder(
        title: 'Lịch Âm Hôm Nay',
        body: 'Xem thông tin chi tiết ngày hôm nay',
        time: _reminderTime,
      );
    } else {
      // Cancel all notifications
      await notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }
  
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_keyReminderTime}_hour', time.hour);
    await prefs.setInt('${_keyReminderTime}_minute', time.minute);
    
    // Update notification schedule if enabled
    if (_notificationsEnabled) {
      final notificationService = NotificationService();
      await notificationService.cancelNotification(0); // Cancel old daily reminder
      await notificationService.scheduleDailyReminder(
        title: 'Lịch Âm Hôm Nay',
        body: 'Xem thông tin chi tiết ngày hôm nay',
        time: time,
      );
    }
    
    notifyListeners();
  }

  Future<void> setCloudSyncEnabled(bool enabled) async {
    _cloudSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCloudSync, enabled);
    notifyListeners();
  }

  Future<void> setWeekStart(int start) async {
    _weekStart = start;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeekStart, start);
    notifyListeners();
  }

  Future<void> setDefaultView(String view) async {
    _defaultView = view;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultView, view);
    notifyListeners();
  }
}

