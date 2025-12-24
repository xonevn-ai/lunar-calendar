import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/settings_provider.dart';
import '../../providers/notes_provider.dart';
import '../../../core/models/calendar_date.dart';
import '../../../core/lunar/lunar_calculator.dart' as lunar_calc;
import '../../../core/canchi/canchi_calculator.dart';
import '../../../core/services/backup_service.dart';

/// Settings Screen - User preferences and app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Card
          _buildInfoCard(context),

          const SizedBox(height: 24),

          // Theme Settings
          _buildSectionHeader('Giao Diện'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Chế độ tối'),
                  subtitle: Text(_getThemeModeText(settingsProvider.themeMode)),
                  value: settingsProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settingsProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.brightness_auto, color: theme.colorScheme.primary),
                  title: const Text('Tự động theo hệ thống'),
                  trailing: Radio<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: settingsProvider.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setThemeMode(value);
                      }
                    },
                  ),
                  onTap: () {
                    settingsProvider.setThemeMode(ThemeMode.system);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.palette, color: theme.colorScheme.primary),
                  title: const Text('Chủ đề'),
                  subtitle: Text(_getThemeName(settingsProvider.selectedTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeSelector(context, settingsProvider);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calendar Settings
          _buildSectionHeader('Lịch'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  title: const Text('Ngày bắt đầu tuần'),
                  subtitle: Text(
                    settingsProvider.weekStart == 0 ? 'Chủ Nhật' : 'Thứ Hai',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showWeekStartSelector(context, settingsProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.view_week, color: theme.colorScheme.primary),
                  title: const Text('Chế độ xem mặc định'),
                  subtitle: Text(_getViewName(settingsProvider.defaultView)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDefaultViewSelector(context, settingsProvider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notifications
          _buildSectionHeader('Thông Báo'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Bật thông báo'),
                  subtitle: const Text('Nhận thông báo về sự kiện và nhắc nhở'),
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotificationsEnabled(value);
                  },
                  secondary: Icon(
                    settingsProvider.notificationsEnabled ? Icons.notifications : Icons.notifications_off,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
                  title: const Text('Thời gian nhắc nhở'),
                  subtitle: Text(
                    '${settingsProvider.reminderTime.hour.toString().padLeft(2, '0')}:${settingsProvider.reminderTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  enabled: settingsProvider.notificationsEnabled,
                  onTap: () {
                    if (!settingsProvider.notificationsEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng bật thông báo trước'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    _showReminderTimePicker(context, settingsProvider);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Sync
          _buildSectionHeader('Dữ Liệu'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Đồng bộ đám mây'),
                  subtitle: const Text('Đồng bộ ghi chú qua Firebase'),
                  value: settingsProvider.cloudSyncEnabled,
                  onChanged: (value) {
                    settingsProvider.setCloudSyncEnabled(value);
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển. Sẽ có trong phiên bản tới.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  secondary: Icon(
                    Icons.cloud_upload,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.backup, color: theme.colorScheme.primary),
                  title: const Text('Sao lưu dữ liệu'),
                  subtitle: const Text('Xuất ghi chú và cài đặt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.restore, color: theme.colorScheme.primary),
                  title: const Text('Khôi phục dữ liệu'),
                  subtitle: const Text('Nhập từ file sao lưu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestoreDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About
          _buildSectionHeader('Thông Tin'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: theme.colorScheme.primary),
                  title: const Text('Về ứng dụng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.star, color: theme.colorScheme.primary),
                  title: const Text('Đánh giá ứng dụng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ứng dụng chưa có trên cửa hàng. Sắp ra mắt!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.share, color: theme.colorScheme.primary),
                  title: const Text('Chia sẻ ứng dụng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Share.share(
                      'Tải ứng dụng Lịch Âm Việt Nam - Ứng dụng lịch âm dương đầy đủ tính năng!',
                      subject: 'Lịch Âm Việt Nam',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showWeekStartSelector(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngày bắt đầu tuần'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Chủ Nhật'),
              value: 0,
              groupValue: settingsProvider.weekStart,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setWeekStart(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đặt ngày bắt đầu tuần là Chủ Nhật'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('Thứ Hai'),
              value: 1,
              groupValue: settingsProvider.weekStart,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setWeekStart(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đặt ngày bắt đầu tuần là Thứ Hai'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    final backupService = BackupService();
    
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Export backup
      if (kIsWeb) {
        // For web, download as JSON string
        final jsonString = await backupService.downloadBackupForWeb();
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
        final fileName = 'lunar_calendar_backup_$timestamp.json';
        
        // Close loading
        if (context.mounted) Navigator.pop(context);
        
        // Use Share to download/copy JSON
        await Share.share(
          jsonString,
          subject: fileName,
        );
      } else {
        // For mobile/desktop, use file system
        final backupFile = await backupService.exportBackup();
        
        // Close loading
        if (context.mounted) Navigator.pop(context);

        // Share file
        if (Platform.isAndroid || Platform.isIOS) {
          await Share.shareXFiles(
            [XFile(backupFile.path)],
            text: 'Sao lưu dữ liệu Lịch Âm Việt Nam',
          );
        } else {
          // For desktop, show file path
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sao lưu thành công'),
                content: Text('File đã được lưu tại:\n${backupFile.path}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sao lưu dữ liệu thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi sao lưu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    final backupService = BackupService();
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu'),
        content: const Text(
          'Việc khôi phục sẽ thay thế dữ liệu hiện tại. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Chọn file sao lưu',
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final file = File(result.files.single.path!);

      // Validate file
      final isValid = await backupService.validateBackupFile(file);
      if (!isValid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File backup không hợp lệ'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Get backup info
      final info = await backupService.getBackupInfo(file);
      
      // Show info and confirm
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông tin backup'),
            content: info != null
                ? Text(
                    'Ngày sao lưu: ${DateTime.parse(info['backupDate'] as String).toString().split('.')[0]}\n'
                    'Số ghi chú: ${info['notesCount']}\n'
                    'Số câu nói: ${info['quotesCount']}\n\n'
                    'Tiếp tục khôi phục?',
                  )
                : const Text('Tiếp tục khôi phục?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Khôi phục'),
              ),
            ],
          ),
        );

        if (proceed != true) return;

        // Show loading again
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Import backup
      await backupService.importBackupFromFile(file, replaceExisting: true);

      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
        
        // Reload providers
        Provider.of<SettingsProvider>(context, listen: false);
        Provider.of<NotesProvider>(context, listen: false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khôi phục dữ liệu thành công! Vui lòng khởi động lại ứng dụng.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi khôi phục: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showReminderTimePicker(BuildContext context, SettingsProvider settingsProvider) {
    showTimePicker(
      context: context,
      initialTime: settingsProvider.reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        settingsProvider.setReminderTime(selectedTime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đặt thời gian nhắc nhở: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildInfoCard(BuildContext context) {
    final now = DateTime.now();
    final solar = SolarDate.fromDateTime(now);
    final lunar = lunar_calc.solarToLunar(solar);
    final yearCanChi = getYearCanChi(lunar.year);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch Âm Việt Nam',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'by Thigio.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Hôm nay',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${solar.day}/${solar.month}/${solar.year}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Text(
                        'Âm lịch',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lunar.day}/${lunar.month}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Text(
                        'Năm',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        yearCanChi.fullName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Chế độ sáng';
      case ThemeMode.dark:
        return 'Chế độ tối';
      case ThemeMode.system:
        return 'Theo hệ thống';
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'default':
        return 'Mặc định';
      case 'spring':
        return 'Mùa Xuân';
      case 'summer':
        return 'Mùa Hạ';
      case 'autumn':
        return 'Mùa Thu';
      case 'winter':
        return 'Mùa Đông';
      case 'tet':
        return 'Tết';
      default:
        return 'Mặc định';
    }
  }

  String _getViewName(String view) {
    switch (view) {
      case 'month':
        return 'Tháng';
      case 'twoWeeks':
        return '2 Tuần';
      case 'week':
        return 'Tuần';
      default:
        return 'Tháng';
    }
  }

  void _showDefaultViewSelector(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn chế độ xem mặc định'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tháng'),
              value: 'month',
              groupValue: settingsProvider.defaultView,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDefaultView(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đặt chế độ xem mặc định là Tháng'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('2 Tuần'),
              value: 'twoWeeks',
              groupValue: settingsProvider.defaultView,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDefaultView(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đặt chế độ xem mặc định là 2 Tuần'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Tuần'),
              value: 'week',
              groupValue: settingsProvider.defaultView,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDefaultView(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đặt chế độ xem mặc định là Tuần'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn chủ đề',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...['default', 'spring', 'summer', 'autumn', 'winter', 'tet'].map((theme) {
              return ListTile(
                title: Text(_getThemeName(theme)),
                leading: Icon(
                  theme == settingsProvider.selectedTheme ? Icons.check_circle : Icons.circle_outlined,
                  color: theme == settingsProvider.selectedTheme
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onTap: () {
                  settingsProvider.setSelectedTheme(theme);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chọn: ${_getThemeName(theme)}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch Âm Việt Nam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'by Thigio.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Version 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Ứng dụng lịch âm dương Việt Nam với đầy đủ tính năng:',
              ),
              SizedBox(height: 8),
              Text('• Chuyển đổi âm/dương lịch'),
              Text('• Can Chi, Hoàng Đạo, Hắc Đạo'),
              Text('• 24 Tiết Khí'),
              Text('• Hướng Xuất Hành, Giờ Xuất Hành'),
              Text('• Ghi chú và nhắc nhở'),
              Text('• Sao lưu và khôi phục dữ liệu'),
              Text('• Tùy chỉnh giao diện (6 themes)'),
              SizedBox(height: 16),
              Text(
                '🌐 Website: thigio.com',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Made with ❤️ for Vietnamese people',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

