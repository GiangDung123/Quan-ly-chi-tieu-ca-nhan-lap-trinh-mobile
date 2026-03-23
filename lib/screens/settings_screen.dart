import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;
  bool _isBiometricEnabled = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tùy chọn ứng dụng',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              value: themeProvider.isDarkMode,
              onChanged: (value) async {
                await themeProvider.toggleTheme(value);
              },
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Chế độ tối'),
              subtitle: const Text('Bật hoặc tắt giao diện tối'),
            ),
          ),

          Card(
            child: SwitchListTile(
              value: _isNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  _isNotificationEnabled = value;
                });
              },
              secondary: const Icon(Icons.notifications_active),
              title: const Text('Thông báo'),
              subtitle: const Text('Nhận nhắc nhở giao dịch và ngân sách'),
            ),
          ),

          Card(
            child: SwitchListTile(
              value: _isBiometricEnabled,
              onChanged: (value) {
                setState(() {
                  _isBiometricEnabled = value;
                });
              },
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Bảo mật sinh trắc học'),
              subtitle: const Text('Mở ứng dụng bằng vân tay hoặc khuôn mặt'),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Khác',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Về ứng dụng'),
              subtitle: const Text('Thông tin phiên bản và mô tả'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showInfoDialog(
                  'Về ứng dụng',
                  'Ứng dụng quản lý tài chính cá nhân được xây dựng bằng Flutter.\nPhiên bản: 1.0.0',
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.green),
              title: const Text('Chính sách bảo mật'),
              subtitle: const Text('Xem thông tin bảo mật dữ liệu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showInfoDialog(
                  'Chính sách bảo mật',
                  'Ứng dụng chỉ lưu dữ liệu cục bộ phục vụ quản lý tài chính cá nhân.',
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.orange),
              title: const Text('Trợ giúp'),
              subtitle: const Text('Hướng dẫn sử dụng ứng dụng'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showInfoDialog(
                  'Trợ giúp',
                  'Bạn có thể thêm giao dịch, quản lý danh mục, đặt ngân sách và xem thống kê ngay từ màn hình chính.',
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}
