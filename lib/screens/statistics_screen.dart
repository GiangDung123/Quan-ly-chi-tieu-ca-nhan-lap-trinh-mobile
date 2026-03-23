import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  bool _isIncome(Map<String, dynamic> transaction) {
    final type = (transaction['type'] ?? '').toString().toLowerCase();
    return type == 'thu nhập' || type == 'income' || type == 'thu';
  }

  double _parseAmount(dynamic amount) {
    if (amount == null) return 0;
    if (amount is num) return amount.toDouble();
    return double.tryParse(amount.toString()) ?? 0;
  }

  Map<String, double> _categoryTotals(
    List<Map<String, dynamic>> transactions,
    bool isIncome,
  ) {
    final Map<String, double> result = {};

    for (final transaction in transactions) {
      final transactionIsIncome = _isIncome(transaction);
      if (transactionIsIncome != isIncome) continue;

      final categoryName =
          (transaction['category'] ?? 'Khác').toString().trim().isEmpty
          ? 'Khác'
          : transaction['category'].toString();

      final amount = _parseAmount(transaction['amount']).abs();

      result[categoryName] = (result[categoryName] ?? 0) + amount;
    }

    final sortedEntries = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {for (final entry in sortedEntries) entry.key: entry.value};
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final List<Map<String, dynamic>> transactions =
        transactionProvider.transactions;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      final amount = _parseAmount(transaction['amount']);

      if (_isIncome(transaction)) {
        totalIncome += amount.abs();
      } else {
        totalExpense += amount.abs();
      }
    }

    final balance = totalIncome - totalExpense;

    final incomeByCategory = _categoryTotals(transactions, true);
    final expenseByCategory = _categoryTotals(transactions, false);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê'), centerTitle: true),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'Chưa có dữ liệu giao dịch để thống kê',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan tài chính',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Tổng thu',
                          value: '${_formatMoney(totalIncome)} đ',
                          icon: Icons.arrow_downward,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Tổng chi',
                          value: '${_formatMoney(totalExpense)} đ',
                          icon: Icons.arrow_upward,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryCard(
                    title: 'Số dư hiện tại',
                    value: '${_formatMoney(balance)} đ',
                    icon: Icons.account_balance_wallet,
                    color: balance >= 0 ? Colors.blue : Colors.orange,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Thống kê thu theo danh mục',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  incomeByCategory.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Chưa có dữ liệu thu nhập'),
                          ),
                        )
                      : Column(
                          children: incomeByCategory.entries.map((entry) {
                            return _buildCategoryTile(
                              category: entry.key,
                              amount: entry.value,
                              color: Colors.green,
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),

                  const Text(
                    'Thống kê chi theo danh mục',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  expenseByCategory.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Chưa có dữ liệu chi tiêu'),
                          ),
                        )
                      : Column(
                          children: expenseByCategory.entries.map((entry) {
                            return _buildCategoryTile(
                              category: entry.key,
                              amount: entry.value,
                              color: Colors.red,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String category,
    required double amount,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.category, color: color),
        ),
        title: Text(category),
        trailing: Text(
          '${_formatMoney(amount)} đ',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
