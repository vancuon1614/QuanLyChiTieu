// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:personal_expense_manager/models/expense.dart';
import 'package:personal_expense_manager/providers/expense_provider.dart';
import 'package:personal_expense_manager/providers/auth_provider.dart'; // <<< THÊM: Import AuthProvider
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng ngày

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = expenseCategories.first; 
  DateTime _selectedDate = DateTime.now();

  // Widget chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm lưu chi tiêu
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      // LẤY USER ID TỪ AUTHDATA
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập để thêm chi tiêu!')),
        );
        return;
      }
      
      final newExpense = Expense(
        id: const Uuid().v4(),
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        userId: userId, // <<< GÁN userId VÀO ĐỐI TƯỢNG
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm chi tiêu thành công!')),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ... (Phần UI giữ nguyên)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Chi Tiêu Mới'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Số tiền
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Số tiền phải là một số dương hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Danh mục (Category)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: expenseCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 3. Ngày
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Chọn Ngày Chi Tiêu'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              const SizedBox(height: 15),

              // 4. Ghi chú
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (Tùy chọn)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Nút Lưu
              ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Lưu Chi Tiêu',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}