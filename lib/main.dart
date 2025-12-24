import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'presentation/screens/home/home_screen.dart';
import 'presentation/providers/calendar_provider.dart';
import 'presentation/providers/notes_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/themes/app_theme.dart';
import 'data/local/hive_storage.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await HiveStorage.init();
  
  // Initialize date formatting for Vietnamese locale
  await initializeDateFormatting('vi', null);
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Lịch Âm Việt Nam - Thigio.com',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(settingsProvider.selectedTheme),
            darkTheme: AppTheme.getDarkTheme(settingsProvider.selectedTheme),
            themeMode: settingsProvider.themeMode,
            // Add localization delegates for date picker and Material widgets
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'), // Vietnamese
              Locale('en', 'US'), // English (fallback)
            ],
            locale: const Locale('vi', 'VN'),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
