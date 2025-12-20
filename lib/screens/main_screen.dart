import 'package:flutter/material.dart';
import 'package:personal_expense_manager/screens/add_expense_screen.dart';
import 'package:personal_expense_manager/screens/history_screen.dart';
import 'package:personal_expense_manager/screens/home_screen.dart';
import 'package:personal_expense_manager/screens/settings_screen.dart';
import 'package:personal_expense_manager/screens/statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),        // Trang chủ
    const HistoryScreen(),      // Lịch sử chi tiêu
    const AddExpenseScreen(),   // Thêm chi tiêu (sẽ được mở từ FAB)
    const StatisticsScreen(),   // Thống kê
    const SettingsScreen(),     // Cài đặt
  ];

  void onItemTapped(int index) {
    if (index == 2) { // 2 là index của nút "Thêm"
      navigateToAddExpense();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex == 2 ? 0 : _selectedIndex], // Nếu bấm nút Thêm thì vẫn hiển thị HomeScreen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Thêm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: onItemTapped,
      ),
    );
  }
}