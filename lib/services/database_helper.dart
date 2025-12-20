import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:personal_expense_manager/models/expense.dart';

class DatabaseHelper { 
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal(); 

  static Database? _database;
  static const String dbName = 'personal_expense_manager.db';

  static const String userTable = 'users'; 
  static const String expenseTable = 'expenses'; 

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Khởi tạo Database và tạo bảng (Có logic tạo 2 bảng)
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: (db, version) async{
      // 1. TẠO BẢNG USERS 
      await db.execute('''
        CREATE TABLE $userTable(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          email TEXT UNIQUE,
          phone TEXT
        )
      ''');

      // 2. TẠO BẢNG EXPENSES
      await db.execute('''
        CREATE TABLE $expenseTable(
          id TEXT PRIMARY KEY,
          description TEXT,
          amount REAL,
          date TEXT, 
          category TEXT,
          userId INTEGER,
          FOREIGN KEY (userId) REFERENCES $userTable (id)
        )
      ''');
    });
  }

  // Lấy User theo username hoặc email (dùng cho Login)
  Future<Map<String, dynamic>?> getUserByUsernameOrEmail(String identifier) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      userTable,
      where: 'username = ? OR email = ?',
      whereArgs: [identifier, identifier],
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
  
  // Lấy User theo ID (dùng cho SettingsScreen)
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
  
  // Đổi mật khẩu
  Future<bool> updatePassword(int userId, String newPassword) async {
    final db = await database;
    final result = await db.update(
      userTable,
      {'password': newPassword}, 
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }
  
  //thêm User (Dùng cho Register)
  Future<bool> insertUser(String username, String password, String email, String phone) async {
    final db = await database;
    // Kiểm tra username hoặc email đã tồn tại chưa
    final existingUser = await db.query(
      userTable,
      where: 'username = ? OR email = ?',
      whereArgs: [username, email],
    );

    if (existingUser.isNotEmpty) {
      return false; // Đăng ký thất bại: Username hoặc Email đã tồn tại
    }

    // Thêm người dùng mới
    await db.insert(
      userTable,
      {'username': username, 'password': password, 'email': email, 'phone': phone},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

 
  
  // lấy chi tiêu theo UserID (Dùng cho ExpenseProvider)
  Future<List<Expense>> getExpensesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      expenseTable,
      where: 'userId = ?', 
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    
    
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]); 
    });
  }


  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      expenseTable,
      expense.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // xóa chi tiêu
  Future<void> deleteExpense(String id, int userId) async {
    final db = await database;
    await db.delete(
      expenseTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}