import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  bool _isIncome(Map<String, dynamic> transaction) {
    final type = (transaction['type'] ?? '').toString().toLowerCase();
    return type == 'thu nhập' || type == 'income' || type == 'thu';
  }

  double _parseAmount(dynamic amount) {
    if (amount == null) return 0;
    if (amount is num) return amount.toDouble();
    return double.tryParse(amount.toString()) ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      final text = value.trim();

      final parsed = DateTime.tryParse(text);
      if (parsed != null) return parsed;

      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);

        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  bool _isInSelectedMonth(Map<String, dynamic> transaction) {
    final date = _parseDate(transaction['date']);
    if (date == null) return false;

    return date.year == _selectedMonth.year &&
        date.month == _selectedMonth.month;
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

  String _formatMonthYear(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ ngày';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn tháng cần xem',
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final List<Map<String, dynamic>> transactions =
        transactionProvider.transactions;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      final amount = _parseAmount(transaction['amount']).abs();

      if (_isIncome(transaction)) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    final balance = totalIncome - totalExpense;

    final incomeByCategory = _categoryTotals(transactions, true);
    final expenseByCategory = _categoryTotals(transactions, false);

    final monthlyTransactions = transactions.where(_isInSelectedMonth).toList();

    double monthlyIncome = 0;
    double monthlyExpense = 0;

    for (final transaction in monthlyTransactions) {
      final amount = _parseAmount(transaction['amount']).abs();

      if (_isIncome(transaction)) {
        monthlyIncome += amount;
      } else {
        monthlyExpense += amount;
      }
    }

    final monthlyBalance = monthlyIncome - monthlyExpense;

    final monthlyIncomeByCategory = _categoryTotals(monthlyTransactions, true);
    final monthlyExpenseByCategory = _categoryTotals(
      monthlyTransactions,
      false,
    );

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

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  const Text(
                    'Thống kê theo tháng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Tháng đang xem'),
                      subtitle: Text(_formatMonthYear(_selectedMonth)),
                      trailing: ElevatedButton(
                        onPressed: () => _pickMonth(context),
                        child: const Text('Chọn tháng'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Thu trong tháng',
                          value: '${_formatMoney(monthlyIncome)} đ',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Chi trong tháng',
                          value: '${_formatMoney(monthlyExpense)} đ',
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryCard(
                    title: 'Số dư trong tháng',
                    value: '${_formatMoney(monthlyBalance)} đ',
                    icon: Icons.savings,
                    color: monthlyBalance >= 0 ? Colors.blue : Colors.orange,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Thu theo danh mục trong tháng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  monthlyIncomeByCategory.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Tháng này chưa có dữ liệu thu nhập'),
                          ),
                        )
                      : Column(
                          children: monthlyIncomeByCategory.entries.map((
                            entry,
                          ) {
                            return _buildCategoryTile(
                              category: entry.key,
                              amount: entry.value,
                              color: Colors.green,
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),

                  const Text(
                    'Chi theo danh mục trong tháng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  monthlyExpenseByCategory.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Tháng này chưa có dữ liệu chi tiêu'),
                          ),
                        )
                      : Column(
                          children: monthlyExpenseByCategory.entries.map((
                            entry,
                          ) {
                            return _buildCategoryTile(
                              category: entry.key,
                              amount: entry.value,
                              color: Colors.red,
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),

                  const Text(
                    'Danh sách giao dịch trong tháng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  monthlyTransactions.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Không có giao dịch nào trong tháng này',
                            ),
                          ),
                        )
                      : Column(
                          children: monthlyTransactions.map((transaction) {
                            final isIncome = _isIncome(transaction);
                            final amount = _parseAmount(
                              transaction['amount'],
                            ).abs();
                            final title = (transaction['title'] ?? '')
                                .toString();
                            final category = (transaction['category'] ?? 'Khác')
                                .toString();
                            final note = (transaction['note'] ?? '').toString();
                            final date = _parseDate(transaction['date']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      (isIncome ? Colors.green : Colors.red)
                                          .withOpacity(0.15),
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(title.isEmpty ? category : title),
                                subtitle: Text(
                                  note.isEmpty
                                      ? '${category} - ${_formatDate(date)}'
                                      : '$category\n$note\n${_formatDate(date)}',
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  '${_formatMoney(amount)} đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
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
