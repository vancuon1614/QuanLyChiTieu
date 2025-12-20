// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_expense_manager/models/expense.dart';
import 'package:personal_expense_manager/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Thêm package intl: ^0.18.1 vào pubspec.yaml

// Lớp tiện ích để định dạng tiền tệ
final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Chi Tiêu'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có giao dịch nào.\nHãy thêm chi tiêu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: expenseProvider.expenses.length,
            itemBuilder: (context, index) {
              final expense = expenseProvider.expenses[index];
              return _buildExpenseItem(context, expense, expenseProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseItem(
      BuildContext context, Expense expense, ExpenseProvider provider) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Xác nhận Xóa"),
              content: const Text("Bạn có chắc chắn muốn xóa giao dịch này?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa giao dịch.')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.withOpacity(0.1),
            child: Icon(_getIconForCategory(expense.category), color: Colors.indigo),
          ),
          title: Text(
            expense.description.isNotEmpty ? expense.description : expense.category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${expense.category} - ${DateFormat('dd/MM/yyyy').format(expense.date)}',
          ),
          trailing: Text(
            '- ${currencyFormatter.format(expense.amount)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Hàm chọn Icon dựa trên Category
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