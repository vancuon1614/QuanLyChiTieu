// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// SỬA LỖI: Import DatabaseHelper từ services
import '../services/database_helper.dart'; 

class AuthProvider with ChangeNotifier {
  // SỬA LỖI: Khởi tạo DatabaseHelper
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoggedIn = false;
  int? _currentUserId;

  bool get isLoggedIn => _isLoggedIn;
  int? get currentUserId => _currentUserId;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  // HÀM: Đăng ký
  Future<bool> register(String username, String password) async {
    final db = await _dbHelper.database;
    try {
      final existingUser = await db.query(
        DatabaseHelper.userTable, // Dùng tên lớp DatabaseHelper
        where: 'username = ?',
        whereArgs: [username],
      );

      if (existingUser.isNotEmpty) return false; 

      await db.insert(
        DatabaseHelper.userTable, // Dùng tên lớp DatabaseHelper
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return false;
    }
  }

  // HÀM: Đăng nhập
  Future<bool> login(String username, String password) async {
    final db = await _dbHelper.database;

    final users = await db.query(
      DatabaseHelper.userTable, // Dùng tên lớp DatabaseHelper
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (users.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = users.first['id'] as int; 
      notifyListeners();
      return true;
    }

    _isLoggedIn = false;
    _currentUserId = null;
    notifyListeners();
    return false;
  }

  // HÀM: Đăng xuất
  void logout() {
    _isLoggedIn = false;
    _currentUserId = null;
    notifyListeners();
  }
}