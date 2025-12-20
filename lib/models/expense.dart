// lib/models/expense.dart

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date; 
  final String description;
  final int? userId; // <<< Bổ sung: ID người dùng

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.userId, // <<< Bổ sung: userId trong constructor
  });

  // Chuyển đối tượng Expense thành Map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(), // Lưu DateTime dưới dạng String ISO8601
      'description': description,
      'userId': userId, // <<< Bổ sung: userId vào toMap
    };
  }

  // Tạo đối tượng Expense từ Map (đọc từ SQLite)
  factory Expense.fromMap(Map<String, dynamic> map) {
    final amountValue = map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'] as double;
    
    return Expense(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: amountValue,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      userId: map['userId'] as int?, // <<< Bổ sung: userId từ fromMap
    );
  }
}

// Danh sách Category
const List<String> expenseCategories = [
  'Ăn uống',
  'Di chuyển',
  'Hóa đơn',
  'Giải trí',
  'Mua sắm',
  'Khác',
];