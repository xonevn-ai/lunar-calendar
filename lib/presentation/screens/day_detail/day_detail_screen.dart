import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/notes_provider.dart';
import '../../../core/models/calendar_date.dart';
import '../../../core/models/can_chi.dart';
import '../../../core/models/element.dart' as core;
import '../../../core/lunar/lunar_calculator.dart' as lunar_calc;
import '../../../core/canchi/canchi_calculator.dart';
import '../../../core/hoangdao/hoangdao_service.dart';
import '../../../core/solar_terms/solar_terms_calculator.dart';
import '../../../core/models/hour_info.dart';
import '../../../core/models/truc_info.dart';
import '../../../core/constants.dart';
import '../../../core/utils/background_service.dart';
import '../../../core/utils/quote_service.dart';
import '../../../data/repositories/holidays_repository.dart';
import '../../../core/models/holiday.dart';
import '../../../core/services/ngay_ky_service.dart';
import '../../../core/services/bang_to_service.dart';
import '../../../core/services/luc_dieu_calculator.dart';
import '../../../core/services/sao_calculator.dart';
import '../../../core/services/ngoc_hap_service.dart';
import '../../../core/services/travel_direction_service.dart';
import '../../../core/services/travel_hour_service.dart';
import '../../../core/models/bang_to.dart';
import '../../../core/models/travel_hour.dart';
import '../notes/notes_list_screen.dart';
import '../notes/note_edit_screen.dart';

/// Day Detail Screen - Shows full information for a selected day
class DayDetailScreen extends StatefulWidget {
  final DateTime date;

  const DayDetailScreen({
    super.key,
    required this.date,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late DateTime _currentDate;
  late FocusNode _focusNode;
  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.date;
    _focusNode = FocusNode();
    _pageController = PageController(initialPage: 1);
    _scrollController = ScrollController();
    // Request focus for keyboard support
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDay(DateTime newDate) {
    setState(() {
      _currentDate = newDate;
    });
    // Update page controller to center position
    _pageController.jumpToPage(1);
  }

  void _goToPreviousDay() {
    _navigateToDay(_currentDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    _navigateToDay(_currentDate.add(const Duration(days: 1)));
  }

  void _goToToday() {
    _navigateToDay(DateTime.now());
  }

  String _getFormattedDateSync(DateTime date) {
    // Use Vietnamese month names
    final monthNames = [
      'Tháng Một',
      'Tháng Hai',
      'Tháng Ba',
      'Tháng Tư',
      'Tháng Năm',
      'Tháng Sáu',
      'Tháng Bảy',
      'Tháng Tám',
      'Tháng Chín',
      'Tháng Mười',
      'Tháng Mười Một',
      'Tháng Mười Hai',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn ngày',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      _navigateToDay(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final solar = SolarDate.fromDateTime(_currentDate);
    final lunar = lunar_calc.solarToLunar(solar);
    final canChi = getFullCanChi(solar);
    final dayQuality = getDayQuality(solar);
    final truc = dayQuality['truc'] as TrucInfo;
    final hoangDaoHours = dayQuality['hoangDaoHours'] as List<HourInfo>;
    final hacDaoHours = dayQuality['hacDaoHours'] as List<HourInfo>;
    
    // Solar Terms
    final solarTermOnDate = getSolarTermOnDate(solar);
    final currentSolarTerm = getCurrentSolarTerm(solar);
    final nextSolarTerm = getNextSolarTerm(solar);
    final daysUntilNext = getDaysUntilNextTerm(solar);

    final backgroundImage = BackgroundService.getBackgroundForDate(_currentDate);
    final quote = QuoteService.getQuoteForDate(_currentDate);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _goToPreviousDay();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _goToNextDay();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getFormattedDateSync(_currentDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousDay,
            tooltip: 'Ngày trước',
          ),
          actions: [
            // Home button - về lịch tháng
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              tooltip: 'Về lịch tháng',
            ),
            // Today button
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: _goToToday,
              tooltip: 'Hôm nay',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _goToNextDay,
              tooltip: 'Ngày sau',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                _shareDayInfo(context, solar, lunar, canChi);
              },
              tooltip: 'Chia sẻ',
            ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe left (negative velocity) = next day
            // Swipe right (positive velocity) = previous day
            if (details.primaryVelocity! < -500) {
              _goToNextDay();
            } else if (details.primaryVelocity! > 500) {
              _goToPreviousDay();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                  BlendMode.overlay,
                ),
              ),
            ),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (index == 0) {
                  _goToPreviousDay();
                } else if (index == 2) {
                  _goToNextDay();
                }
              },
              itemBuilder: (context, index) {
                // Only render the current day (index 1)
                if (index != 1) {
                  return const SizedBox.shrink();
                }
                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true, // Always show scrollbar on web
                  interactive: true, // Enable dragging the scrollbar
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Random Quote Card with glass effect
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: _buildQuoteCard(context, quote),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Solar and Lunar Date Card with glass effect
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: _buildDateCard(context, solar, lunar),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Can Chi Card
              _buildCanChiCard(context, canChi),
              
              const SizedBox(height: 16),
              
              // Trực Card
              _buildTrucCard(context, truc),
              
              const SizedBox(height: 16),
              
              // Solar Term Card
              _buildSolarTermCard(
                context,
                solarTermOnDate,
                currentSolarTerm,
                nextSolarTerm,
                daysUntilNext,
              ),
              
              const SizedBox(height: 16),
              
              // Holidays Card
              _buildHolidaysCard(context, _currentDate),
              
              const SizedBox(height: 16),
              
              // Các Ngày Kỵ Card
              _buildNgayKyCard(context, solar),
              
              const SizedBox(height: 16),
              
              // Bành Tổ Bách Kỵ Nhật Card
              _buildBangToCard(context, solar),
              
              const SizedBox(height: 16),
              
              // Khổng Minh Lục Diệu Card
              _buildLucDieuCard(context, solar),
              
              const SizedBox(height: 16),
              
              // Nhị Thập Bát Tú Card
              _buildSaoCard(context, solar),
              
              const SizedBox(height: 16),
              
              // Ngọc Hạp Thông Thư Card
              _buildNgocHapCard(context, solar),
              
              // Hướng Xuất Hành Card
              _buildTravelDirectionCard(context, solar),
              
              // Giờ Xuất Hành Theo Lý Thuần Phong Card
              _buildTravelHoursCard(context, solar),
              
              const SizedBox(height: 16),
              
              // Hoàng Đạo Hours Card
              _buildHoursCard(
                context,
                'Giờ Hoàng Đạo',
                hoangDaoHours,
                HourType.hoangdao,
              ),
              
              const SizedBox(height: 16),
              
              // Hắc Đạo Hours Card
              _buildHoursCard(
                context,
                'Giờ Hắc Đạo',
                hacDaoHours,
                HourType.hacdao,
              ),
              
              const SizedBox(height: 16),
              
              // Notes Card
              _buildNotesCard(context, solar),
                      ],
                    ),
                  ),
                );
              },
              itemCount: 3, // Previous, Current, Next
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, SolarDate solar) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = notesProvider.getNotesForDate(solar);
        final notesCount = notes.length;

        return Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ghi Chú',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$notesCount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (notes.isEmpty)
                  Text(
                    'Chưa có ghi chú cho ngày này',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...notes.take(3).map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteEditScreen(note: note),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          if (note.color != null)
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _parseColor(note.color!),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          else
                            const SizedBox(width: 4),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (note.content.isNotEmpty)
                                  Text(
                                    note.content,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                if (notes.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesListScreen(filterDate: solar),
                          ),
                        );
                      },
                      child: Text('Xem tất cả (${notes.length})'),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(solarDate: solar),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm ghi chú'),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  Widget _buildDateCard(BuildContext context, SolarDate solar, LunarDate lunar) {
    final yearCanChi = getYearCanChi(lunar.year);
    final monthCanChi = getMonthCanChi(lunar.year, lunar.month);
    final dayCanChi = getDayCanChi(solar);
    
    return Card(
      elevation: 2,
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
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Thông Tin Ngày',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dương lịch
                Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dương lịch',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark 
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${solar.day}/${solar.month}/${solar.year}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.orange.shade300
                                : Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Âm lịch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.nightlight_round, 
                        color: isDark 
                            ? Colors.indigo.shade300
                            : Colors.indigo.shade700, 
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Âm lịch',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lunar.day}/${lunar.month}${lunar.isLeapMonth ? " (Nhuận)" : ""}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.indigo.shade200
                                    : Colors.indigo.shade900,
                              ),
                            ),
                            Text(
                              'Tháng ${lunar.monthName}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? Colors.grey.shade200
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Can Chi năm
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCanChiItem(context, 'Năm', yearCanChi.fullName, yearCanChi.element),
                        _buildCanChiItem(context, 'Tháng', monthCanChi.fullName, monthCanChi.element),
                        _buildCanChiItem(context, 'Ngày', dayCanChi.fullName, dayCanChi.element),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCanChiItem(BuildContext context, String label, String value, core.Element element) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getElementColor(context, element).withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getElementColor(context, element).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            element.name,
            style: TextStyle(
              fontSize: 10,
              color: _getElementColor(context, element),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanChiCard(BuildContext context, Map<String, CanChi> canChi) {
    final yearCanChi = canChi['year']!;
    final monthCanChi = canChi['month']!;
    final dayCanChi = canChi['day']!;
    
    // Get animal from year's Chi
    final yearAnimal = diaChi[yearCanChi.chi].animal;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Can Chi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Năm ${yearCanChi.fullName} - ${yearAnimal}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCanChiRow(context, 'Năm', yearCanChi, yearAnimal),
            const Divider(height: 24),
            _buildCanChiRow(context, 'Tháng', monthCanChi),
            const Divider(height: 24),
            _buildCanChiRow(context, 'Ngày', dayCanChi),
            if (yearCanChi.napAm != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nạp Âm',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            yearCanChi.napAm!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCanChiRow(BuildContext context, String label, CanChi canChi, [String? animal]) {
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canChi.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (animal != null)
                Text(
                  'Con $animal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getElementColor(context, canChi.element).withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getElementColor(context, canChi.element),
              width: 1.5,
            ),
          ),
          child: Text(
            canChi.element.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getElementColor(context, canChi.element),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrucCard(BuildContext context, TrucInfo truc) {
    final isGood = truc.type == TrucType.hoangdao;
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isGood ? Icons.star : Icons.warning,
                    color: isGood
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trực: ${truc.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isGood
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      isGood ? 'Hoàng Đạo' : 'Hắc Đạo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: isGood
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            if (truc.goodFor.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tốt cho:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: truc.goodFor.map((item) => Chip(
                  label: Text(item),
                  labelStyle: const TextStyle(fontSize: 12),
                )).toList(),
              ),
            ],
            if (truc.badFor.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Không tốt cho:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: truc.badFor.map((item) => Chip(
                  label: Text(item),
                  labelStyle: const TextStyle(fontSize: 12),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHoursCard(
    BuildContext context,
    String title,
    List<HourInfo> hours,
    HourType type,
  ) {
    final isGood = type == HourType.hoangdao;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGood ? Icons.wb_sunny : Icons.nightlight_round,
                  color: isGood
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${hours.length} giờ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...hours.map((hour) => _buildHourRow(context, hour, isGood)),
          ],
        ),
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, HourInfo hour, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isGood
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isGood
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.error.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                '${hour.startHour}-${hour.endHour}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isGood
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            Expanded(
              child: Text(
                hour.chiName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hour.starName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            ),
            if (hour.meaning != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: hour.meaning!,
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSolarTermCard(
    BuildContext context,
    dynamic solarTermOnDate,
    dynamic currentSolarTerm,
    dynamic nextSolarTerm,
    int daysUntilNext,
  ) {
    final hasTermToday = solarTermOnDate != null;
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_twilight,
                    color: hasTermToday
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '24 Tiết Khí',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasTermToday
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : null,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (hasTermToday) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hôm nay là: ${solarTermOnDate.name}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          if (solarTermOnDate.chineseName.isNotEmpty)
                            Text(
                              solarTermOnDate.chineseName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Text(
                'Tiết khí hiện tại:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentSolarTerm.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (currentSolarTerm.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  currentSolarTerm.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiết khí tiếp theo:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${nextSolarTerm.name} (${nextSolarTerm.date.day}/${nextSolarTerm.date.month})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Còn $daysUntilNext ngày',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.95),
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
    ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, String quote) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                quote,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidaysCard(BuildContext context, DateTime date) {
    final holidays = HolidaysRepository.getHolidaysForDate(date);
    
    if (holidays.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày Lễ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...holidays.map((holiday) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (holiday.icon != null)
                      Text(
                        holiday.icon!,
                        style: const TextStyle(fontSize: 24),
                      )
                    else
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holiday.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (holiday.description != null)
                            Text(
                              holiday.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getHolidayTypeColor(context, holiday.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getHolidayTypeColor(context, holiday.type),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getHolidayTypeLabel(holiday.type),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getHolidayTypeColor(context, holiday.type),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHolidayTypeColor(BuildContext context, HolidayType type) {
    switch (type) {
      case HolidayType.public:
        return Colors.blue;
      case HolidayType.traditional:
        return Colors.orange;
      case HolidayType.religious:
        return Colors.purple;
    }
  }

  String _getHolidayTypeLabel(HolidayType type) {
    switch (type) {
      case HolidayType.public:
        return 'Công lịch';
      case HolidayType.traditional:
        return 'Truyền thống';
      case HolidayType.religious:
        return 'Tôn giáo';
    }
  }

  Widget _buildNgayKyCard(BuildContext context, SolarDate solar) {
    final ngayKyList = NgayKyService.getNgayKyForDate(solar);
    
    if (ngayKyList.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Các Ngày Kỵ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...ngayKyList.map((ngayKy) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ngayKy.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ngayKy.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (ngayKy.avoidActivities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: ngayKy.avoidActivities.map((activity) => Chip(
                          label: Text(activity),
                          labelStyle: const TextStyle(fontSize: 12),
                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLucDieuCard(BuildContext context, SolarDate solar) {
    final lucDieu = LucDieuCalculator.calculateForDate(solar);
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: lucDieu.isGood
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lucDieu.isGood
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    lucDieu.isGood ? Icons.star : Icons.warning,
                    color: lucDieu.isGood
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Khổng Minh Lục Diệu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lucDieu.isGood
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lucDieu.displayName,
                      style: TextStyle(
                        color: lucDieu.isGood
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lucDieu.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buổi sáng',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lucDieu.morningStatus,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: lucDieu.morningStatus.contains('Tốt')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buổi chiều',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lucDieu.afternoonStatus,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: lucDieu.afternoonStatus.contains('Tốt')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (lucDieu.poem.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lucDieu.poem,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (lucDieu.goodFor.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Tốt cho:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: lucDieu.goodFor.map((activity) => Chip(
                    label: Text(activity),
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList(),
                ),
              ],
              if (lucDieu.avoid.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Nên tránh:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: lucDieu.avoid.map((activity) => Chip(
                    label: Text(activity),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaoCard(BuildContext context, SolarDate solar) {
    final sao = SaoCalculator.getSaoForDate(solar);
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: sao.isGood
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sao.isGood
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    sao.isGood ? Icons.star : Icons.star_border,
                    color: sao.isGood
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nhị Thập Bát Tú',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sao.isGood
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sao.isGood ? 'Kiết Tú' : 'Hung Tú',
                      style: TextStyle(
                        color: sao.isGood
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tên sao: ${sao.displayName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tên ngày: ${sao.dayName}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${sao.animal} - ${sao.element} tinh, ${sao.isGood ? "sao tốt" : "sao xấu"}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (sao.goodFor.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Nên làm:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: sao.goodFor.map((activity) => Chip(
                    label: Text(activity),
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList(),
                ),
              ],
              if (sao.avoid.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Kiêng cữ:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: sao.avoid.map((activity) => Chip(
                    label: Text(activity),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  )).toList(),
                ),
              ],
              if (sao.poem.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sao.poem,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (sao.exception != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngoại lệ:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sao.exception!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              if (sao.phucDoanSat != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phục Đoạn Sát:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sao.phucDoanSat!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgocHapCard(BuildContext context, SolarDate solar) {
    final goodStars = NgocHapService.getGoodStarsForDate(solar);
    final badStars = NgocHapService.getBadStarsForDate(solar);
    
    if (goodStars.isEmpty && badStars.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ngọc Hạp Thông Thư',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (goodStars.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sao tốt',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...goodStars.map((star) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              star.displayName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              star.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (star.affects.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: star.affects.map((affect) => Chip(
                                  label: Text(affect),
                                  labelStyle: const TextStyle(fontSize: 11),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                )).toList(),
                              ),
                            ],
                            if (star.exception != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Lưu ý: ${star.exception}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              if (badStars.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sao xấu',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...badStars.map((star) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              star.displayName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              star.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (star.affects.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: star.affects.map((affect) => Chip(
                                  label: Text(affect),
                                  labelStyle: const TextStyle(fontSize: 11),
                                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                )).toList(),
                              ),
                            ],
                            if (star.exception != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Lưu ý: ${star.exception}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTravelDirectionCard(BuildContext context, SolarDate solar) {
    final directions = TravelDirectionService.getDirectionsForDate(solar);
    final goodDirections = directions.where((d) => d.type == 'good').toList();
    final badDirections = directions.where((d) => d.type == 'bad').toList();

    if (directions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hướng Xuất Hành',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (goodDirections.isNotEmpty) ...[
              Text(
                'Hướng Tốt:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
              ),
              const SizedBox(height: 8),
              ...goodDirections.map((direction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                direction.direction,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                              Text(
                                '${direction.deity}: ${direction.description}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            if (badDirections.isNotEmpty) ...[
              Text(
                'Hướng Xấu:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
              ),
              const SizedBox(height: 8),
              ...badDirections.map((direction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                direction.direction,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                              ),
                              Text(
                                '${direction.deity}: ${direction.description}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTravelHoursCard(BuildContext context, SolarDate solar) {
    final travelHours = TravelHourService.getTravelHoursForDate(solar);
    final goodHours = travelHours.where((h) => h.isGood).toList();
    final badHours = travelHours.where((h) => !h.isGood).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Giờ Xuất Hành Theo Lý Thuần Phong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (goodHours.isNotEmpty) ...[
              Text(
                'Giờ Tốt:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
              ),
              const SizedBox(height: 8),
              ...goodHours.map((travelHour) => _buildTravelHourItem(context, travelHour, true)),
              const SizedBox(height: 16),
            ],
            if (badHours.isNotEmpty) ...[
              Text(
                'Giờ Xấu:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
              ),
              const SizedBox(height: 8),
              ...badHours.map((travelHour) => _buildTravelHourItem(context, travelHour, false)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTravelHourItem(BuildContext context, TravelHour travelHour, bool isGood) {
    final color = isGood ? Colors.green[700] : Colors.red[700];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isGood ? Colors.green : Colors.red).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color!.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGood ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${travelHour.hour.chiName} (${travelHour.hour.hourRange})',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ),
                if (travelHour.direction != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      travelHour.direction!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              travelHour.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (travelHour.activities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: travelHour.activities.map((activity) => Chip(
                      label: Text(
                        activity,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: color.withOpacity(0.1),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
              ),
            ],
            if (travelHour.warning != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        travelHour.warning!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange[700],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBangToCard(BuildContext context, SolarDate solar) {
    final prohibitions = BangToService.getAllProhibitionsForDate(solar);
    
    if (prohibitions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bành Tổ Bách Kỵ Nhật',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...prohibitions.map((prohibition) {
                final type = prohibition['type'] as String;
                final name = prohibition['name'] as String;
                final prohibitionData = prohibition['prohibition'];
                
                if (prohibitionData == null) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$type: $name',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (prohibitionData is BangTo) ...[
                        Text(
                          prohibitionData.vietnameseProhibition,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${prohibitionData.prohibition}"',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (prohibitionData.avoidActivities.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: prohibitionData.avoidActivities.map((activity) => Chip(
                              label: Text(activity),
                              labelStyle: const TextStyle(fontSize: 12),
                            )).toList(),
                          ),
                        ],
                      ] else if (prohibitionData is BangToChi) ...[
                        Text(
                          prohibitionData.vietnameseProhibition,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${prohibitionData.prohibition}"',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (prohibitionData.avoidActivities.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: prohibitionData.avoidActivities.map((activity) => Chip(
                              label: Text(activity),
                              labelStyle: const TextStyle(fontSize: 12),
                            )).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Color _getElementColor(BuildContext context, core.Element element) {
    final colors = {
      core.Element.kim: Colors.grey.shade400,
      core.Element.moc: Colors.green.shade400,
      core.Element.thuy: Colors.blue.shade400,
      core.Element.hoa: Colors.red.shade400,
      core.Element.tho: Colors.brown.shade400,
    };
    return colors[element] ?? Colors.grey.shade400;
  }

  /// Share day information
  void _shareDayInfo(
    BuildContext context,
    SolarDate solar,
    LunarDate lunar,
    Map<String, CanChi> canChi,
  ) {
    final yearCanChi = canChi['year']!;
    final monthCanChi = canChi['month']!;
    final dayCanChi = canChi['day']!;
    
    final goodHours = getGoodHours(solar);
    final hourText = goodHours
        .map((h) => '${h.chiName} (${h.startHour}-${h.endHour})')
        .join(', ');
    
    final shareText = '''
📅 Lịch Âm Việt Nam

Dương lịch: ${solar.day}/${solar.month}/${solar.year}
Âm lịch: ${lunar.day}/${lunar.month}${lunar.isLeapMonth ? " (Nhuận)" : ""}/${lunar.year}

Can Chi:
• Năm: ${yearCanChi.fullName} - ${diaChi[yearCanChi.chi].animal}
• Tháng: ${monthCanChi.fullName}
• Ngày: ${dayCanChi.fullName}

Giờ Hoàng Đạo: $hourText

#LichAmVietNam #LichAmDuong
''';
    
    Share.share(shareText, subject: 'Thông tin ngày ${solar.day}/${solar.month}/${solar.year}');
  }
}

