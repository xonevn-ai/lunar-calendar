# 📋 TODO & Roadmap - Lịch Âm Việt Nam

**Last Updated**: December 2025  
**Status**: Version 1.0.0 - Core features complete, optional enhancements pending

---

## 🎯 Priority Classification

- 🔴 **High Priority**: Tính năng quan trọng, nên làm sớm
- 🟡 **Medium Priority**: Tính năng hữu ích, có thể làm sau
- 🟢 **Low Priority**: Nice to have, optional

---

## 🔴 High Priority Features

### 1. Notifications System
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/core/services/notification_service.dart`
- **Description**: Local notifications cho events và reminders
- **Tasks**:
  - [x] Setup `flutter_local_notifications` properly
  - [x] Create notification service
  - [x] Add notification scheduling
  - [x] Create notification settings UI
  - [x] Handle notification permissions
- **Completed**: December 2025

### 2. Backup/Restore Functionality
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/core/services/backup_service.dart`
- **Description**: Export/import notes và settings
- **Tasks**:
  - [x] Create backup service
  - [x] Export to JSON file
  - [x] Import from JSON file
  - [x] Add file picker for import
  - [x] Add share functionality for backup
  - [x] Web platform support
- **Completed**: December 2025

---

## 🟡 Medium Priority Features

### 3. Week Start Selector
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/presentation/screens/settings/settings_screen.dart`
- **Description**: Cho phép user chọn ngày bắt đầu tuần (Thứ 2, Chủ Nhật, etc.)
- **Tasks**:
  - [x] Add setting to SettingsProvider
  - [x] Create selector dialog
  - [x] Update calendar grid to respect week start
  - [x] Persist setting
- **Completed**: December 2025

### 4. Default View Selector
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/presentation/screens/settings/settings_screen.dart`
- **Description**: Remember user's preferred calendar view (Month/Week/2 Weeks)
- **Tasks**:
  - [x] Add setting to SettingsProvider
  - [x] Create selector
  - [x] Update calendar to use default view
  - [x] Persist setting
- **Completed**: December 2025
- **Note**: Implemented Month, Week, and 2 Weeks views

### 5. Reminder Time Selector
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/presentation/screens/settings/settings_screen.dart`
- **Description**: Cho phép user chọn thời gian nhắc nhở hàng ngày
- **Tasks**:
  - [x] Add setting to SettingsProvider
  - [x] Create time picker dialog
  - [x] Integrate với notifications system
  - [x] Persist setting
- **Completed**: December 2025

### 6. Hướng Xuất Hành (Travel Directions)
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/core/services/travel_direction_service.dart`
- **Description**: Hiển thị hướng tốt/xấu cho xuất hành
- **Tasks**:
  - [x] Create model cho travel directions
  - [x] Create service để calculate directions dựa trên Can Chi
  - [x] Add card trong Day Detail screen
  - [x] Display với compass icon hoặc direction indicators
  - [x] Show good directions (green) và bad directions (red)
- **Completed**: December 2025

### 7. Giờ Xuất Hành Theo Lý Thuần Phong
- **Status**: ✅ **Completed in v1.0.0**
- **Location**: `lib/core/services/travel_hour_service.dart`
- **Description**: Hour-by-hour travel guidance
- **Tasks**:
  - [x] Create model cho travel hours với description
  - [x] Create service để calculate theo Can Chi và giờ
  - [x] Add card trong Day Detail screen
  - [x] Display theo từng giờ (12 canh) với status (tốt/xấu)
  - [x] Color code: green cho tốt, red cho xấu
- **Completed**: December 2025

---

## 🟢 Low Priority Features

### 8. Enhanced Ngũ Hành Display
- **Status**: ⏳ Pending
- **Description**: Detailed Five Elements analysis với conflicts và harmonies
- **Tasks**:
  - [ ] Create detailed Ngũ Hành model
  - [ ] Add calculation logic
  - [ ] Create visual display
  - [ ] Add to Day Detail screen
- **Estimated Time**: 4-6 hours

### 9. App Store Rating
- **Status**: ⏳ Pending
- **Location**: `lib/presentation/screens/settings/settings_screen.dart` (line 235)
- **Description**: Open app store để user đánh giá
- **Tasks**:
  - [ ] Add `url_launcher` integration
  - [ ] Create app store URLs
  - [ ] Handle platform-specific URLs
- **Estimated Time**: 1 hour
- **Dependencies**: `url_launcher` (already available)

### 10. Cloud Sync (Firebase)
- **Status**: ⏳ Pending
- **Description**: Sync notes và settings qua Firebase
- **Tasks**:
  - [ ] Setup Firebase project
  - [ ] Add Firebase dependencies
  - [ ] Create sync service
  - [ ] Implement authentication
  - [ ] Add sync UI
- **Estimated Time**: 16-24 hours
- **Dependencies**: Firebase setup, authentication
- **Note**: Currently commented out in pubspec.yaml due to web compatibility

### 11. Login/Authentication
- **Status**: ⏳ Pending
- **Description**: User authentication cho cloud sync
- **Tasks**:
  - [ ] Choose auth method (Firebase Auth, etc.)
  - [ ] Create auth service
  - [ ] Create login screen
  - [ ] Handle auth state
- **Estimated Time**: 8-12 hours
- **Dependencies**: Firebase or other auth service

### 12. Week/Day Calendar Views
- **Status**: ⏳ Pending
- **Description**: Thêm Week view và Day view cho calendar
- **Tasks**:
  - [ ] Create Week view widget
  - [ ] Create Day view widget
  - [ ] Add view switcher
  - [ ] Update CalendarProvider
- **Estimated Time**: 12-16 hours

### 13. Background Image Caching
- **Status**: ⏳ Pending
- **Description**: Cache background images locally thay vì load từ URL mỗi lần
- **Tasks**:
  - [ ] Download và cache images
  - [ ] Store paths in Hive
  - [ ] Update BackgroundService
- **Estimated Time**: 4-6 hours
- **Note**: Hiện tại đã dùng `cached_network_image` nhưng có thể cải thiện

---

## 🐛 Bug Fixes & Improvements

### Code Quality
- [x] ✅ Fix Nạp Âm calculation (đã fix)
- [x] ✅ Remove unused imports (đã fix)
- [x] ✅ Fix TODO comments với user feedback (đã fix)
- [ ] Add more unit tests
- [ ] Add widget tests
- [ ] Improve error handling coverage

### Performance
- [ ] Optimize calendar calculations (caching)
- [ ] Lazy load day detail content
- [ ] Optimize image loading

### UI/UX Polish
- [ ] Add skeleton loaders
- [ ] Add more smooth animations
- [ ] Improve loading states
- [ ] Add pull-to-refresh
- [ ] Add haptic feedback

---

## 📊 Implementation Priority

### Phase 1: Essential Features (1-2 weeks)
1. 🔴 Notifications System (#1)
2. 🔴 Backup/Restore (#2)
3. 🟡 Week Start Selector (#3)
4. 🟡 Reminder Time Selector (#5)

### Phase 2: Traditional Features (1-2 weeks)
5. 🟡 Hướng Xuất Hành (#6)
6. 🟡 Giờ Xuất Hành Theo Lý Thuần Phong (#7)
7. 🟢 Enhanced Ngũ Hành (#8)

### Phase 3: Advanced Features (2-3 weeks)
8. 🟢 Cloud Sync (#10)
9. 🟢 Login/Authentication (#11)
10. 🟢 Week/Day Views (#12)

### Phase 4: Polish (1 week)
11. 🟢 App Store Rating (#9)
12. 🟢 Background Caching (#13)
13. UI/UX improvements
14. Performance optimizations

---

## 📝 Quick Wins (Easy to Implement)

### < 2 hours
- [x] ✅ Fix TODO comments (đã làm)
- [ ] App Store Rating (#9) - 1 hour
- [ ] Week Start Selector (#3) - 3-4 hours

### 2-4 hours
- [ ] Reminder Time Selector (#5) - 2-3 hours
- [ ] Default View Selector (#4) - 2-3 hours (nếu đã có Week/Day views)

### 4-8 hours
- [ ] Backup/Restore (#2) - 6-8 hours
- [ ] Hướng Xuất Hành (#6) - 4-6 hours

---

## 🎯 Current Focus

**Recommended Next Steps**:
1. **Notifications System** - High value, có dependency sẵn
2. **Backup/Restore** - High value, dễ implement
3. **Hướng Xuất Hành** - Traditional feature, users expect

---

## 📌 Notes

- Tất cả core features đã hoàn thành ✅
- Các tính năng trong TODO list là optional enhancements
- App hiện tại đã production-ready
- Có thể release và thêm features sau

---

**Last Updated**: 23 December 2025  
**Total TODO Items**: 13 features + improvements

