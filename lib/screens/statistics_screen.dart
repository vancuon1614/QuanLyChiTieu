// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_expense_manager/models/expense.dart';
import 'package:personal_expense_manager/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Chi Tiêu'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu để thống kê.'),
            );
          }

          final data = _getDailyExpenseData(expenseProvider.expenses);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Xu hướng Chi tiêu (7 Ngày Gần Nhất)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                  ),
                  child: LineChart(
                    _getLineChartData(data),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Phân tích theo Danh mục',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildCategorySummary(expenseProvider.expenses),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LOGIC XỬ LÝ DỮ LIỆU BIỂU ĐỒ ---

  // 1. Tạo dữ liệu chi tiêu hàng ngày (7 ngày gần nhất)
  Map<DateTime, double> _getDailyExpenseData(List<Expense> expenses) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
    final Map<DateTime, double> dailyTotals = {};

    // Khởi tạo 7 ngày gần nhất với tổng chi tiêu bằng 0
    for (int i = 0; i < 7; i++) {
      final date = sevenDaysAgo.add(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      dailyTotals[dayKey] = 0.0;
    }

    // Cộng dồn chi tiêu
    for (var expense in expenses) {
      final dayKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + expense.amount;
      }
    }
    return dailyTotals;
  }

  // 2. Tạo LineChartData
  LineChartData _getLineChartData(Map<DateTime, double> dailyData) {
    final sortedDates = dailyData.keys.toList()..sort();
    double maxAmount = dailyData.values.reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) maxAmount = 100; // Tránh chia cho 0

    // Chuyển Map thành List<FlSpot>
    final List<FlSpot> spots = sortedDates
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final amount = dailyData[entry.value] ?? 0;
      return FlSpot(index, amount);
    })
        .toList();

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: true),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final date = sortedDates[value.toInt()];
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4.0,
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              String text;
              if (value == 0) {
                text = '0';
              } else if (value == maxAmount) {
                text = (maxAmount / 1000).toStringAsFixed(0) + 'K';
              } else {
                text = '';
              }
              return Text(text, style: const TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.indigo,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.indigo.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  // 3. Xây dựng Summary Category
  Widget _buildCategorySummary(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      total += expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) {
        final percentage = (entry.value / total) * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}