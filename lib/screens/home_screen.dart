// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_expense_manager/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_manager/screens/main_screen.dart';

// Lớp tiện ích để định dạng tiền tệ (cũng có trong history_screen)
final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ', decimalDigits: 0);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy provider
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final totalExpense = expenseProvider.getTotalExpenseForCurrentMonth();
    final recentExpenses = expenseProvider.expenses.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Chi Tiêu'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Tổng chi tiêu tháng
            _buildTotalExpenseCard(totalExpense),
            const SizedBox(height: 20),

            // 2. Tiêu đề Giao dịch Gần đây
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch Gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // lib/screens/home_screen.dart

TextButton(
  onPressed: () {
    // Gọi đúng tên State đã public
    final mainScreenState = context.findAncestorStateOfType<MainScreenState>(); 
    // Gọi hàm đã public
    mainScreenState?.onItemTapped(1); 
  },
  child: const Text('Xem tất cả >'),
),
              ],
            ),
            const Divider(),

            // 3. Danh sách Giao dịch Gần đây
            recentExpenses.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                  child: Text('Bạn chưa có giao dịch nào gần đây.',
                      style: TextStyle(color: Colors.grey))),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentExpenses.length,
              itemBuilder: (context, index) {
                final expense = recentExpenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    child: Icon(_getIconForCategory(expense.category),
                        color: Colors.indigo),
                  ),
                  title: Text(
                    expense.description.isNotEmpty
                        ? expense.description
                        : expense.category,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(expense.date)),
                  trailing: Text(
                    '- ${currencyFormatter.format(expense.amount)}',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tổng chi tiêu
  Widget _buildTotalExpenseCard(double totalExpense) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tổng Chi Tiêu Tháng Này',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            currencyFormatter.format(totalExpense),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tính đến ngày ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm chọn Icon dựa trên Category (Tái sử dụng từ history_screen)
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.fastfood;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Hóa đơn':
        return Icons.receipt_long;
      case 'Giải trí':
        return Icons.movie;
      case 'Mua sắm':
        return Icons.shopping_bag;
      default:
        return Icons.credit_card;
    }
  }
}