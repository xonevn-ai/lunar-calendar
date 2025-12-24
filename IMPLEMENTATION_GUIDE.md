# 🚀 Implementation Guide - Missing Features

This guide provides specific implementation steps for missing features and improvements.

---

## 🎯 Priority 1: Quick UI Improvements

### 1. Add Swipe Gestures to Day Detail Screen

**File**: `lib/presentation/screens/day_detail/day_detail_screen.dart`

**Changes Needed**:
```dart
// Wrap the body in a PageView for swipe navigation
PageView.builder(
  controller: PageController(initialPage: 0),
  onPageChanged: (index) {
    // Navigate to previous/next day
    final newDate = date.add(Duration(days: index == 0 ? -1 : 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DayDetailScreen(date: newDate)),
    );
  },
  itemBuilder: (context, index) {
    // Your existing body content
  },
)
```

**Alternative**: Use `GestureDetector` with `onHorizontalDragEnd`

### 2. Add Previous/Next Day Buttons

**File**: `lib/presentation/screens/day_detail/day_detail_screen.dart`

**Add to AppBar actions**:
```dart
actions: [
  IconButton(
    icon: Icon(Icons.chevron_left),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DayDetailScreen(date: date.subtract(Duration(days: 1))),
        ),
      );
    },
  ),
  IconButton(
    icon: Icon(Icons.chevron_right),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DayDetailScreen(date: date.add(Duration(days: 1))),
        ),
      );
    },
  ),
  // ... existing share button
],
```

### 3. Add Keyboard Support (Desktop)

**File**: `lib/presentation/screens/day_detail/day_detail_screen.dart`

**Add FocusNode and KeyboardListener**:
```dart
class _DayDetailScreenState extends State<DayDetailScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // Previous day
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Next day
          }
        }
      },
      child: Scaffold(...),
    );
  }
}
```

---

## 🎯 Priority 2: Database Improvements

### 1. Move Quotes to Hive Storage

**Create Model**: `lib/core/models/quote.dart`
```dart
import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 1)
class Quote extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final String? author;
  
  @HiveField(3)
  final DateTime createdAt;
  
  Quote({
    required this.id,
    required this.text,
    this.author,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
```

**Update QuoteService**: `lib/core/utils/quote_service.dart`
```dart
class QuoteService {
  static Box<Quote>? _quotesBox;
  
  static Future<void> init() async {
    _quotesBox = await Hive.openBox<Quote>('quotes');
    // Load default quotes if empty
    if (_quotesBox!.isEmpty) {
      await _loadDefaultQuotes();
    }
  }
  
  static Future<void> _loadDefaultQuotes() async {
    // Add default quotes from current hardcoded list
  }
  
  static String getQuoteForDate(DateTime date) {
    // Get quote from database based on date
    // Use date as seed for consistency
  }
}
```

### 2. Move Backgrounds to Local Storage

**Create Model**: `lib/core/models/background.dart`
```dart
@HiveType(typeId: 2)
class Background extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String url;
  
  @HiveField(2)
  final String? localPath; // For cached images
  
  @HiveField(3)
  final bool isCustom;
  
  Background({
    required this.id,
    required this.url,
    this.localPath,
    this.isCustom = false,
  });
}
```

**Update BackgroundService**: Cache images locally using `cached_network_image` or download and store.

---

## 🎯 Priority 3: Missing Traditional Features

### 1. Implement Các Ngày Kỵ

**Create Model**: `lib/core/models/ngay_ky.dart`
```dart
class NgayKy {
  final String id;
  final String name;
  final String description;
  final List<String> avoidActivities;
  
  NgayKy({
    required this.id,
    required this.name,
    required this.description,
    required this.avoidActivities,
  });
}
```

**Create Service**: `lib/core/services/ngay_ky_service.dart`
```dart
class NgayKyService {
  static List<NgayKy> getNgayKyForDate(SolarDate date) {
    // Calculate based on Can Chi and other factors
    // Return list of days to avoid
  }
}
```

**Add to Day Detail Screen**: Display in a new card section.

### 2. Implement Bành Tổ Bách Kỵ Nhật

**Create Constants**: Add to `lib/core/constants.dart`
```dart
const Map<String, Map<String, String>> bangToBachKyNhat = {
  'Giáp': {
    'name': 'Giáp',
    'prohibition': 'Bất khai khẩu, tất kiến họa',
    'description': 'Không nên mở miệng để tránh họa',
  },
  'Ất': {
    'name': 'Ất',
    'prohibition': 'Bất tu táo, tất kiến hỏa ương',
    'description': 'Không nên sửa chữa bếp để tránh hỏa tai',
  },
  // ... continue for all 10 Can
};
```

**Create Service**: `lib/core/services/bang_to_service.dart`
```dart
class BangToService {
  static Map<String, String> getProhibitionForCan(String can) {
    return bangToBachKyNhat[can] ?? {};
  }
}
```

### 3. Implement Khổng Minh Lục Diệu

**Create Model**: `lib/core/models/luc_dieu.dart`
```dart
enum LucDieuType {
  tocHy,      // Tốc Hỷ
  xichKhau,   // Xích Khẩu
  tieuCat,    // Tiểu Cát
  khongVong,  // Không Vong
  daiAn,      // Đại An
  luuLien,    // Lưu Liên
}

class LucDieu {
  final LucDieuType type;
  final String name;
  final String description;
  final bool isGood;
  final String morningStatus;
  final String afternoonStatus;
  
  LucDieu({
    required this.type,
    required this.name,
    required this.description,
    required this.isGood,
    required this.morningStatus,
    required this.afternoonStatus,
  });
}
```

**Create Calculator**: `lib/core/services/luc_dieu_calculator.dart`
```dart
class LucDieuCalculator {
  static LucDieu calculateForDate(SolarDate date) {
    // Calculate based on lunar day and Can Chi
    // Return appropriate LucDieu
  }
}
```

### 4. Implement Nhị Thập Bát Tú (28 Stars)

**Create Model**: `lib/core/models/sao.dart`
```dart
class Sao {
  final int index; // 1-28
  final String name;
  final String chineseName;
  final String element; // Kim, Mộc, Thủy, Hỏa, Thổ
  final bool isGood;
  final List<String> goodFor;
  final List<String> avoid;
  final String poem; // Traditional poem
  
  Sao({
    required this.index,
    required this.name,
    required this.chineseName,
    required this.element,
    required this.isGood,
    required this.goodFor,
    required this.avoid,
    required this.poem,
  });
}
```

**Create Calculator**: `lib/core/services/sao_calculator.dart`
```dart
class SaoCalculator {
  static Sao getSaoForDate(SolarDate date) {
    // Calculate which star (1-28) for the date
    // Based on lunar month and day
  }
}
```

### 5. Implement Ngọc Hạp Thông Thư

**Create Model**: `lib/core/models/ngoc_hap.dart`
```dart
enum SaoType {
  good,
  bad,
}

class NgocHapSao {
  final String name;
  final String chineseName;
  final SaoType type;
  final List<String> affects; // What it affects
  final String? exception; // Exception conditions
  
  NgocHapSao({
    required this.name,
    required this.chineseName,
    required this.type,
    required this.affects,
    this.exception,
  });
}
```

**Create Service**: `lib/core/services/ngoc_hap_service.dart`
```dart
class NgocHapService {
  static List<NgocHapSao> getGoodStarsForDate(SolarDate date) {
    // Calculate good stars
  }
  
  static List<NgocHapSao> getBadStarsForDate(SolarDate date) {
    // Calculate bad stars
  }
}
```

---

## 🎯 Priority 4: Holidays System

### 1. Create Holiday Model

**File**: `lib/core/models/holiday.dart`
```dart
enum HolidayType {
  public,      // Public holiday
  traditional, // Traditional festival
  religious,   // Religious holiday
}

class Holiday {
  final String id;
  final String name;
  final String vietnameseName;
  final HolidayType type;
  final SolarDate? solarDate;  // For fixed solar holidays
  final LunarDate? lunarDate;  // For lunar holidays
  final bool isRecurring;
  final String? description;
  
  Holiday({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.type,
    this.solarDate,
    this.lunarDate,
    this.isRecurring = true,
    this.description,
  });
}
```

### 2. Create Holidays Database

**File**: `lib/data/repositories/holidays_repository.dart`
```dart
class HolidaysRepository {
  static final List<Holiday> _holidays = [
    // Solar holidays
    Holiday(
      id: 'new_year',
      name: 'New Year',
      vietnameseName: 'Tết Dương Lịch',
      type: HolidayType.public,
      solarDate: SolarDate(year: 0, month: 1, day: 1),
    ),
    // Lunar holidays
    Holiday(
      id: 'tet',
      name: 'Tet',
      vietnameseName: 'Tết Nguyên Đán',
      type: HolidayType.traditional,
      lunarDate: LunarDate(year: 0, month: 1, day: 1, isLeapMonth: false, monthName: ''),
    ),
    // ... more holidays
  ];
  
  static List<Holiday> getHolidaysForDate(DateTime date) {
    // Return holidays for specific date
  }
}
```

### 3. Display Holidays in Calendar

**Update**: `lib/presentation/widgets/calendar/calendar_grid.dart`
- Add holiday markers to calendar cells
- Show holiday names in day detail screen

---

## 🎯 Priority 5: Enhanced Features

### 1. Hướng Xuất Hành (Travel Directions)

**Create Service**: `lib/core/services/travel_direction_service.dart`
```dart
class TravelDirectionService {
  static Map<String, String> getDirectionsForDate(SolarDate date) {
    return {
      'good': 'Tây Nam', // For Hỷ Thần
      'good2': 'Chính Đông', // For Tài Thần
      'bad': 'Chính Nam', // For Hạc Thần
    };
  }
}
```

### 2. Giờ Xuất Hành Theo Lý Thuần Phong

**Create Model**: `lib/core/models/travel_hour.dart`
```dart
class TravelHour {
  final HourInfo hour;
  final String description;
  final bool isGood;
  final String? direction;
  final List<String> activities;
  
  TravelHour({
    required this.hour,
    required this.description,
    required this.isGood,
    this.direction,
    required this.activities,
  });
}
```

**Create Service**: `lib/core/services/travel_hour_service.dart`
```dart
class TravelHourService {
  static List<TravelHour> getTravelHoursForDate(SolarDate date) {
    // Calculate travel hours based on Can Chi
    // Return list of TravelHour with descriptions
  }
}
```

---

## 📝 Implementation Checklist

### Week 1
- [ ] Add swipe gestures to Day Detail screen
- [ ] Add previous/next day buttons
- [ ] Move quotes to Hive storage
- [ ] Create Holiday model and basic holidays list

### Week 2
- [ ] Implement Các Ngày Kỵ
- [ ] Implement Bành Tổ Bách Kỵ Nhật
- [ ] Implement Khổng Minh Lục Diệu
- [ ] Display holidays in calendar

### Week 3
- [ ] Implement Nhị Thập Bát Tú
- [ ] Implement Ngọc Hạp Thông Thư
- [ ] Move backgrounds to local storage
- [ ] Improve calendar UI

### Week 4
- [ ] Implement Hướng Xuất Hành
- [ ] Implement Giờ Xuất Hành Theo Lý Thuần Phong
- [ ] Add keyboard support (desktop)
- [ ] Testing and bug fixes

---

## 🔧 Technical Notes

1. **Hive Adapters**: Remember to run `flutter pub run build_runner build` after creating new Hive models
2. **Testing**: Add unit tests for all new calculators and services
3. **Performance**: Cache calculations where possible
4. **Localization**: All text should be in Vietnamese
5. **Error Handling**: Add proper error handling for all new features

---

**Last Updated**: 23 December 2025

