# 🌙 Lịch Âm Việt Nam - Thigio.com

Ứng dụng lịch âm dương Việt Nam đa nền tảng (Android, iOS, Web PWA) được xây dựng với Flutter/Dart.

🌐 **Website**: [https://thigio.com](https://thigio.com)  
📱 **Demo**: [https://thigio.com](https://thigio.com)  
📄 **License**: [MIT](LICENSE)

## 📋 Status

**Current Phase**: ✅ **Version 1.0.0 - Production Ready**

### ✅ Completed Features

#### Core Functionality
- ✅ Lunar calendar calculations (solarToLunar, lunarToSolar)
- ✅ Can Chi system (Year, Month, Day) với Nạp Âm chính xác
- ✅ Hoàng Đạo/Hắc Đạo hours
- ✅ 24 Tiết Khí (Solar Terms)
- ✅ Trực system (12 Trực)

#### Traditional Vietnamese Calendar Features
- ✅ **Các Ngày Kỵ** - Days to avoid for specific activities
- ✅ **Bành Tổ Bách Kỵ Nhật** - Traditional prohibitions
- ✅ **Khổng Minh Lục Diệu** - Six day types
- ✅ **Nhị Thập Bát Tú** - 28 Stars system
- ✅ **Ngọc Hạp Thông Thư** - Good/Bad stars
- ✅ **Hướng Xuất Hành** - Travel directions based on Can Chi
- ✅ **Giờ Xuất Hành Theo Lý Thuần Phong** - Hour-by-hour travel guidance
- ✅ **Holidays** - 13+ Vietnamese holidays (solar & lunar)

#### UI/UX Features
- ✅ Home screen với calendar grid (Month/Week/2 Weeks views)
- ✅ Day Detail screen với đầy đủ thông tin truyền thống
- ✅ Notes system (CRUD) với Hive storage
- ✅ Theme system (Light/Dark) với 6 color themes
- ✅ Swipe gestures để navigate
- ✅ Keyboard support (arrow keys) cho desktop
- ✅ Previous/Next/Today/Home buttons
- ✅ Date picker để chọn ngày nhanh
- ✅ Backup/Restore functionality
- ✅ Notifications với daily reminders

#### Data Persistence
- ✅ Quotes stored in Hive
- ✅ Notes stored in Hive
- ✅ Settings persistence

### ✅ Version 1.0.0 Features

**All Core Features Completed:**
- ✅ Notifications system với daily reminders
- ✅ Backup/Restore functionality (JSON export/import)
- ✅ Hướng Xuất Hành (Travel directions)
- ✅ Giờ Xuất Hành Theo Lý Thuần Phong
- ✅ Week/2 Weeks calendar views
- ✅ Settings improvements:
  - Week start selector (Sunday/Monday)
  - Default view selector (Month/Week/2 Weeks)
  - Reminder time configuration
  - Theme selector (6 themes: Default, Spring, Summer, Autumn, Winter, Tet)

### 📅 Future Enhancements (Optional)

Xem **[TODO_ROADMAP.md](TODO_ROADMAP.md)** để biết danh sách các tính năng tùy chọn.

**Low Priority**:
- [ ] Cloud sync (Firebase)
- [ ] Login/Authentication
- [ ] Enhanced Ngũ Hành display
- [ ] App Store rating integration

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters (required for Notes)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS (macOS only)
flutter run -d ios

# Run on Desktop
flutter run -d windows    # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux
```

### 🖥️ Desktop Build

Xem [DESKTOP_BUILD_GUIDE.md](DESKTOP_BUILD_GUIDE.md) để biết chi tiết về cách build cho desktop.

## 📁 Project Structure

```
lib/
├── core/              # Business logic (pure Dart)
│   ├── lunar/        # Lunar calendar calculations
│   ├── canchi/       # Can Chi calculations
│   ├── hoangdao/     # Hoàng Đạo/Hắc Đạo
│   ├── solar_terms/  # 24 Tiết Khí
│   ├── suncalc/      # Sunrise/Sunset
│   └── models/       # Data models
│
├── data/             # Data layer
│   ├── local/        # Hive, SQLite
│   ├── remote/       # Firebase
│   └── repositories/ # Data repositories
│
├── presentation/      # UI layer
│   ├── screens/      # App screens
│   ├── widgets/      # Reusable widgets
│   ├── themes/       # App themes
│   └── providers/    # State management
│
└── utils/            # Utilities
```

## 📚 Documentation

- **[CHANGELOG.md](CHANGELOG.md)** - Version history và changes
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for contributing
- **[FINAL_IMPLEMENTATION_SUMMARY.md](FINAL_IMPLEMENTATION_SUMMARY.md)** - Complete feature list và implementation details
- **[DESKTOP_BUILD_GUIDE.md](DESKTOP_BUILD_GUIDE.md)** - Hướng dẫn build cho desktop
- **[PROJECT_REVIEW.md](PROJECT_REVIEW.md)** - Detailed project analysis
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Implementation reference
- **[TODO_ROADMAP.md](TODO_ROADMAP.md)** - Future enhancements roadmap

## 🛠️ Development

### State Management
- **Provider**: Được sử dụng cho state management
- **Hive**: Local storage cho notes và settings

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Platforms

- ✅ Android
- ✅ iOS  
- ✅ Web (PWA)
- ✅ Desktop (Windows/Mac/Linux) - Ready to build

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌐 Website & Demo

- **Website**: [https://thigio.com](https://thigio.com)
- **Live Demo**: [https://thigio.com](https://thigio.com)

## 👨‍💻 Author

**Thigio.com**

Made with ❤️ for Vietnamese people
