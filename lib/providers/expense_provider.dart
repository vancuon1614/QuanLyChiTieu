// lib/providers/expense_provider.dart

import 'package:flutter/foundation.dart';
import 'package:personal_expense_manager/models/expense.dart';
import 'package:personal_expense_manager/services/database_helper.dart'; 

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Expense> get expenses => _expenses;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  // HÀM: Cập nhật UserID khi AuthProvider thay đổi
  void updateAuthData(int? userId) {
    if (userId != _currentUserId) {
      _currentUserId = userId;
      // Tự động tải lại chi tiêu khi UserID thay đổi (Đăng nhập/Đăng xuất)
      fetchExpenses();
    }
  }

  // HÀM TẢI DỮ LIỆU ĐÃ SỬA TÊN VÀ SỬ DỤNG USERID
  Future<void> fetchExpenses() async {
    if (_currentUserId == null) {
      _expenses = []; // Không có UserID thì không có chi tiêu
      notifyListeners();
      return;
    }
    _expenses = await _dbHelper.getExpensesByUserId(_currentUserId!); 
    notifyListeners();
  }

  // Hàm thêm chi tiêu
  Future<void> addExpense(Expense expense) async {
    if (_currentUserId == null) return; 
    await _dbHelper.insertExpense(expense); 
    await fetchExpenses(); 
  }

  // Hàm xóa chi tiêu
  Future<void> deleteExpense(String id) async {
    if (_currentUserId == null) return;
    await _dbHelper.deleteExpense(id, _currentUserId!); 
    await fetchExpenses(); 
  }

  // Lấy tổng chi tiêu trong tháng hiện tại
  double getTotalExpenseForCurrentMonth() {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}