import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../core/models/calendar_date.dart';
import '../../../core/lunar/lunar_calculator.dart';
import '../../../core/canchi/canchi_calculator.dart';
import '../../../core/constants.dart';
import '../../../core/utils/background_service.dart';
import '../../../core/utils/vietnamese_calendar_locale.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/calendar/calendar_grid.dart';
import '../day_detail/day_detail_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen - Main calendar view
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundImage = BackgroundService.getBackgroundForDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Âm Việt Nam'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final currentMode = settingsProvider.themeMode;
              if (currentMode == ThemeMode.system) {
                settingsProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
              } else {
                settingsProvider.setThemeMode(
                  currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                );
              }
            },
            tooltip: 'Chuyển đổi chế độ sáng/tối',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () async {
              final notificationService = NotificationService();
              final pending = await notificationService.getPendingNotifications();
              
              if (pending.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không có thông báo nào đang chờ'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thông báo đã lên lịch'),
                    content: Text('Có ${pending.length} thông báo đang chờ'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              }
            },
            tooltip: 'Thông báo',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              BlendMode.overlay,
            ),
          ),
        ),
        child: Consumer<CalendarProvider>(
          builder: (context, calendarProvider, child) {
            final selectedDate = calendarProvider.selectedDate;
            final solar = SolarDate.fromDateTime(selectedDate);
            final lunar = solarToLunar(solar);
            // DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
            // VietnameseCalendarLocale.getDayName expects: 0=Sunday, 1=Monday, ..., 6=Saturday
            // Convert: 1->1, 2->2, ..., 6->6, 7->0
            final weekday = selectedDate.weekday % 7;

            return Column(
              children: [
                // Month header
                _buildMonthHeader(context, calendarProvider),
                
                // Today's info card (clickable to view details)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DayDetailScreen(date: selectedDate),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi mở chi tiết: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: _buildTodayInfoCard(context, solar, lunar, weekday),
                  ),
                ),
              
              // Calendar grid with glass effect
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: CalendarGrid(
                          focusedDay: calendarProvider.focusedDate,
                          selectedDay: selectedDate,
                          calendarFormat: _getCalendarFormatFromString(settingsProvider.defaultView),
                          onDaySelected: (date) {
                            try {
                              calendarProvider.selectDate(date);
                              // Navigate to day detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DayDetailScreen(date: date),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CalendarProvider>().goToToday(),
        child: const Icon(Icons.today),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, CalendarProvider provider) {
    final month = provider.focusedDate.month;
    final year = provider.focusedDate.year;
    final solar = SolarDate.fromDateTime(provider.focusedDate);
    final lunar = solarToLunar(solar);
    final yearCanChi = getYearCanChi(lunar.year);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () => provider.goToPreviousMonth(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Tháng $month/$year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                        Text(
                          'Năm ${yearCanChi.fullName} - ${diaChi[yearCanChi.chi].animal}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () => provider.goToNextMonth(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayInfoCard(BuildContext context, SolarDate solar, LunarDate lunar, int weekday) {
    final dayCanChi = getDayCanChi(solar);
    final yearCanChi = getYearCanChi(lunar.year);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hôm nay',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Dương lịch',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${solar.day}/${solar.month}/${solar.year}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        Text(
                          VietnameseCalendarLocale.getDayName(weekday),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.nightlight_round, size: 16, color: Colors.indigo.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Âm lịch',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lunar.day}/${lunar.month}${lunar.isLeapMonth ? " (Nhuận)" : ""}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                        Text(
                          'Tháng ${lunar.monthName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.indigo.shade200
                                : Colors.indigo.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Can Chi Ngày',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayCanChi.fullName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey.shade400,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Năm',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          yearCanChi.fullName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          diaChi[yearCanChi.chi].animal,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CalendarFormat _getCalendarFormatFromString(String view) {
    switch (view) {
      case 'week':
        return CalendarFormat.week;
      case 'twoWeeks':
        return CalendarFormat.twoWeeks;
      case 'month':
      default:
        return CalendarFormat.month;
    }
  }
}

