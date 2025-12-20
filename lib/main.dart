import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo DatabaseHelper
  await getDatabasesPath().database;

  runApp(const MyApp());
}

extension on Future<String> {
  Future<void>? get database => null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 2. ExpenseProvider 
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, expense) {
            
            expense!.updateAuthData(auth.currentUserId);
            return expense;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Personal Expense Manager',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),

        home: const AuthCheckScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}


class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      
      return const MainScreen();
    } else {
      
      return const LoginScreen();
    }
  }
}