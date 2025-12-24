import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../core/models/calendar_date.dart';
import '../../../core/lunar/lunar_calculator.dart';
import '../../../core/hoangdao/hoangdao_service.dart';
import '../../../core/constants.dart';
import '../../../data/repositories/holidays_repository.dart';
import '../../../core/utils/vietnamese_calendar_locale.dart';
import '../../providers/settings_provider.dart';

// Import isSameDay helper from table_calendar
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Calendar Grid Widget using table_calendar
/// Displays both solar and lunar dates
class CalendarGrid extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final CalendarFormat calendarFormat;

  const CalendarGrid({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.calendarFormat = CalendarFormat.month,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _calendarFormat = widget.calendarFormat;
  }

  @override
  void didUpdateWidget(CalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
    if (oldWidget.calendarFormat != widget.calendarFormat) {
      _calendarFormat = widget.calendarFormat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Convert weekStart (0=Sunday, 1=Monday) to StartingDayOfWeek
    final startingDayOfWeek = settingsProvider.weekStart == 0
        ? StartingDayOfWeek.sunday
        : StartingDayOfWeek.monday;
    
    return TableCalendar<dynamic>(
      firstDay: DateTime(minYear, 1, 1),
      lastDay: DateTime(maxYear, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      calendarFormat: _calendarFormat,
      startingDayOfWeek: startingDayOfWeek,
      locale: 'vi_VN',
      availableCalendarFormats: const {
        CalendarFormat.month: 'Tháng',
        CalendarFormat.twoWeeks: '2 Tuần',
        CalendarFormat.week: 'Tuần',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        selectedTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        formatButtonTextStyle: TextStyle(
          color: theme.colorScheme.onSecondaryContainer,
        ),
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          return VietnameseCalendarLocale.formatMonthYear(date);
        },
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: theme.colorScheme.onSurface,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
        // Save to settings
        final viewString = _getStringFromCalendarFormat(format);
        settingsProvider.setDefaultView(viewString);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          return _DayCell(
            date: date,
            isToday: isSameDay(date, DateTime.now()),
            isSelected: isSameDay(date, widget.selectedDay),
          );
        },
        todayBuilder: (context, date, _) {
          return _DayCell(
            date: date,
            isToday: true,
            isSelected: isSameDay(date, widget.selectedDay),
          );
        },
        selectedBuilder: (context, date, _) {
          return _DayCell(
            date: date,
            isToday: isSameDay(date, DateTime.now()),
            isSelected: true,
          );
        },
      ),
    );
  }

  String _getStringFromCalendarFormat(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.week:
        return 'week';
      case CalendarFormat.twoWeeks:
        return 'twoWeeks';
      case CalendarFormat.month:
        return 'month';
    }
  }
}

/// Individual day cell with solar and lunar date
class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate lunar date
    final solar = SolarDate(
      year: date.year,
      month: date.month,
      day: date.day,
    );
    final lunar = solarToLunar(solar);
    
    // Check special days
    final isLunarFirst = lunar.day == 1; // Mùng 1
    final isLunarFifteenth = lunar.day == 15; // Rằm
    final isHoangDao = isHoangDaoDay(solar);
    final isHacDao = !isHoangDao;
    
    // Check holidays
    final holidays = HolidaysRepository.getHolidaysForDate(date);
    final hasHoliday = holidays.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
        maxWidth: 50,
        maxHeight: 50,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : isToday
                ? theme.colorScheme.primaryContainer
                : null,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : null,
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Solar date - larger for today
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: isToday ? 15 : 13,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isToday
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Lunar date with special styling
                Text(
                  '${lunar.day}',
                  style: TextStyle(
                    fontSize: isToday ? 11 : 10,
                    fontWeight: (isLunarFirst || isLunarFifteenth) ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withOpacity(0.95)
                        : isToday
                            ? theme.colorScheme.onPrimaryContainer.withOpacity(0.9)
                            : (isLunarFirst || isLunarFifteenth)
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Hoàng Đạo / Hắc Đạo indicator - small dot
          if (isHoangDao || isHacDao)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHoangDao ? Colors.red : Colors.black,
                  boxShadow: isHoangDao
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.8),
                            blurRadius: 2,
                            spreadRadius: 0.3,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 2,
                            spreadRadius: 0.3,
                          ),
                        ],
                ),
              ),
            ),
          // Holiday indicator - star icon
          if (hasHoliday)
            Positioned(
              bottom: 1,
              left: 1,
              child: Container(
                width: 10,
                height: 10,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  size: 6,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

