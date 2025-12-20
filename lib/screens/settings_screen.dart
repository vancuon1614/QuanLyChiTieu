// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_expense_manager/providers/auth_provider.dart'; 
import 'package:provider/provider.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Hàm Đăng xuất gọi AuthProvider
  void _logout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đăng xuất.')),
    );
  }

  // Widget xây dựng phần thông tin cá nhân
  Widget _buildProfileSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUserId;
    
    final usernameText = currentUserId != null 
        ? 'Người dùng ID: $currentUserId' 
        : 'Chưa đăng nhập';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Tài Khoản',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Tên Người Dùng'),
          subtitle: Text(usernameText),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Đổi Mật Khẩu'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng đổi mật khẩu đang phát triển.')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Cài Đặt Chung',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.currency_exchange),
          title: const Text('Đơn Vị Tiền Tệ'),
          subtitle: const Text('VNĐ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Ngôn Ngữ'),
          subtitle: const Text('Tiếng Việt'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Về Ứng Dụng'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt & Tài Khoản'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildProfileSection(context),
            const Divider(),
            _buildSettingsSection(context),
            const Divider(),

            // Nút Đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng Xuất',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}