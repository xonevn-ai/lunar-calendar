# 🖥️ Desktop Build Guide - Lịch Âm Việt Nam

Hướng dẫn compile và chạy ứng dụng trên desktop (Windows, macOS, Linux).

---

## ✅ Prerequisites

### Windows
- ✅ Visual Studio 2022 với "Desktop development with C++"
- ✅ Windows 10 SDK (version 10.0.19041.0 or higher)
- ✅ CMake (thường đi kèm với Visual Studio)

### macOS
- ✅ Xcode (latest version)
- ✅ CocoaPods: `sudo gem install cocoapods`
- ✅ Command Line Tools: `xcode-select --install`

### Linux
- ✅ Các packages cần thiết:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```

---

## 🚀 Setup & Build

### 1. Enable Desktop Support

```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Enable macOS desktop (macOS only)
flutter config --enable-macos-desktop

# Enable Linux desktop (Linux only)
flutter config --enable-linux-desktop
```

### 2. Verify Desktop Support

```bash
flutter doctor
```

Kiểm tra xem desktop platform có được enable không:
- ✅ Windows: "Visual Studio - develop Windows apps"
- ✅ macOS: "Xcode - develop for iOS and macOS"
- ✅ Linux: "Linux toolchain - develop for Linux"

### 3. Check Available Devices

```bash
flutter devices
```

Bạn sẽ thấy:
- `Windows (desktop)` - cho Windows
- `macOS (desktop)` - cho macOS
- `Linux (desktop)` - cho Linux

---

## 📦 Dependencies Check

### ✅ Desktop-Compatible Dependencies

Các dependencies sau đã được kiểm tra và tương thích với desktop:

- ✅ **Hive** - Local storage (hoạt động tốt trên desktop)
- ✅ **Provider** - State management (cross-platform)
- ✅ **table_calendar** - Calendar widget (cross-platform)
- ✅ **intl** - Internationalization (cross-platform)
- ✅ **url_launcher** - URL launching (có desktop support)
- ✅ **share_plus** - Sharing (có desktop support)
- ✅ **cached_network_image** - Image caching (cross-platform)
- ✅ **flutter_animate** - Animations (cross-platform)

### ⚠️ Dependencies Cần Lưu Ý

Các dependencies sau có thể cần cấu hình đặc biệt hoặc không được sử dụng:

- ⚠️ **sqflite** - SQLite database
  - **Status**: Có trong pubspec.yaml nhưng không được sử dụng trong code
  - **Desktop**: Có thể hoạt động nhưng cần test
  - **Recommendation**: Nếu không dùng, có thể remove

- ⚠️ **flutter_local_notifications** - Local notifications
  - **Status**: Có trong pubspec.yaml nhưng không được sử dụng trong code
  - **Desktop**: Cần cấu hình đặc biệt cho desktop
  - **Recommendation**: Nếu không dùng, có thể remove hoặc thêm conditional import

- ⚠️ **geolocator** & **geocoding** - Location services
  - **Status**: Có trong pubspec.yaml nhưng không được sử dụng trong code
  - **Desktop**: Cần permission và cấu hình đặc biệt
  - **Recommendation**: Nếu không dùng, có thể remove

---

## 🔨 Build Commands

### Windows

```bash
# Run in debug mode
flutter run -d windows

# Build release
flutter build windows --release

# Build with specific configuration
flutter build windows --release --split-debug-info=./debug-info
```

**Output**: `build\windows\x64\runner\Release\lunar_calendar_flutter.exe`

### macOS

```bash
# Run in debug mode
flutter run -d macos

# Build release
flutter build macos --release

# Build app bundle
flutter build macos --release
```

**Output**: `build\macos\Build\Products\Release\lunar_calendar_flutter.app`

### Linux

```bash
# Run in debug mode
flutter run -d linux

# Build release
flutter build linux --release
```

**Output**: `build\linux\x64\release\bundle\lunar_calendar_flutter`

---

## 🧪 Testing Desktop Build

### Quick Test

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Build và Test Release

```bash
# Build release
flutter build windows --release

# Run the built executable
# Windows: build\windows\x64\runner\Release\lunar_calendar_flutter.exe
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "No devices found"

**Solution**:
```bash
# Enable desktop support
flutter config --enable-windows-desktop
flutter doctor
```

### Issue 2: CMake errors (Windows)

**Solution**:
- Đảm bảo Visual Studio đã cài "Desktop development with C++"
- Chạy Visual Studio Installer và thêm component này

### Issue 3: Dependencies không tương thích

**Solution**:
- Kiểm tra dependencies có được sử dụng không
- Nếu không dùng, có thể remove hoặc thêm conditional import
- Sử dụng `kIsWeb` hoặc `Platform.isWindows` để conditional import

### Issue 4: Build errors với sqflite/notifications

**Solution**:
- Nếu không sử dụng, remove khỏi pubspec.yaml
- Hoặc thêm conditional import:
  ```dart
  import 'package:flutter/foundation.dart';
  
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // Desktop-specific code
  }
  ```

### Issue 5: Symlink errors (geolocator_windows, etc.)

**Error**: `PathExistsException: Cannot create link, path = '...\geolocator_windows'`

**Solution**:
```bash
# Clean build folder
flutter clean

# Remove symlinks manually (if needed)
# Windows: Delete folder windows\flutter\ephemeral\.plugin_symlinks\
# Linux/Mac: rm -rf windows/flutter/ephemeral/.plugin_symlinks/

# Get dependencies again
flutter pub get

# Try build again
flutter build windows --debug
```

### Issue 6: CMake platform mismatch error

**Error**: `CMake Error: Error: generator platform: x64 Does not match the platform used previously`

**Solution**:
```bash
# Easiest solution - Clean everything
flutter clean

# Get dependencies again
flutter pub get

# Then rebuild
flutter build windows --release
```

**Manual cleanup (if flutter clean doesn't work)**:

**Windows (CMD)**:
```cmd
del /f /q build\windows\CMakeCache.txt
rmdir /s /q build\windows\CMakeFiles
del /f /q windows\CMakeCache.txt
rmdir /s /q windows\CMakeFiles
```

**Windows (PowerShell)**:
```powershell
Remove-Item -Path "build\windows\CMakeCache.txt" -ErrorAction SilentlyContinue
Remove-Item -Path "build\windows\CMakeFiles" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "windows\CMakeCache.txt" -ErrorAction SilentlyContinue
Remove-Item -Path "windows\CMakeFiles" -Recurse -ErrorAction SilentlyContinue
```

**Linux/Mac**:
```bash
rm -rf build/windows/CMakeCache.txt
rm -rf build/windows/CMakeFiles
rm -rf windows/CMakeCache.txt
rm -rf windows/CMakeFiles
```

---

## 📝 Pre-Build Checklist

Trước khi build cho desktop:

- [ ] Chạy `flutter pub get`
- [ ] Chạy `flutter pub run build_runner build` (nếu có Hive models)
- [ ] Kiểm tra `flutter doctor` - đảm bảo desktop toolchain OK
- [ ] Test trên debug mode trước: `flutter run -d windows`
- [ ] Kiểm tra các dependencies có được sử dụng không
- [ ] Remove unused dependencies nếu có

---

## 🎯 Build for Distribution

### Windows

```bash
# Build release
flutter build windows --release

# Tạo installer (cần thêm tool như Inno Setup hoặc NSIS)
# Output: build\windows\x64\runner\Release\
```

### macOS

```bash
# Build release
flutter build macos --release

# Tạo DMG (cần thêm tool)
# Output: build\macos\Build\Products\Release\
```

### Linux

```bash
# Build release
flutter build linux --release

# Tạo AppImage hoặc DEB package (cần thêm tool)
# Output: build\linux\x64\release\bundle\
```

---

## 📊 Current Status

### Desktop Support Status

- ✅ **Windows**: Ready to build
- ✅ **macOS**: Ready to build (nếu có Mac)
- ✅ **Linux**: Ready to build (nếu có Linux)

### Dependencies Status

- ✅ **Core dependencies**: All compatible
- ⚠️ **Optional dependencies**: sqflite, notifications, geolocator - không được sử dụng, có thể remove

### Known Issues

- Không có issues nghiêm trọng
- Tất cả dependencies chính đều tương thích desktop

---

## 🚀 Quick Start

```bash
# 1. Enable desktop (nếu chưa)
flutter config --enable-windows-desktop

# 2. Clean build (nếu có lỗi symlink)
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Run on desktop (debug mode)
flutter run -d windows

# 6. Build release
flutter build windows --release
```

### ⚡ Quick Test

```bash
# Test run (nhanh nhất)
flutter run -d windows

# Build debug (để test)
flutter build windows --debug

# Build release (để distribute)
flutter build windows --release
```

---

**Last Updated**: 23 December 2025  
**Tested On**: Windows 10/11

