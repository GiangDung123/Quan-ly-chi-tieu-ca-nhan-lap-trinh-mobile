import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/icon_helper.dart';
import 'transaction_detail_screen.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = ['Tất cả', 'Chi tiêu', 'Thu nhập'];

  List<Map<String, dynamic>> _getFilteredTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    if (_selectedFilter == 'Tất cả') {
      return transactions;
    }
    return transactions
        .where((item) => item['type'] == _selectedFilter)
        .toList();
  }

  String _formatAmount(int amount) {
    final value = amount.abs().toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    final result = buffer.toString().split('').reversed.join();
    return amount >= 0 ? '+$result đ' : '-$result đ';
  }

  Color _amountColor(int amount) {
    return amount >= 0 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = _getFilteredTransactions(provider.transactions);

    final totalIncome = transactions
        .where((item) => item['amount'] > 0)
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    final totalExpense = transactions
        .where((item) => item['amount'] < 0)
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'Tổng quan giao dịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryBox(
                        title: 'Thu nhập',
                        value: _formatAmount(totalIncome),
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryBox(
                        title: 'Chi tiêu',
                        value: _formatAmount(totalExpense),
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Không có giao dịch nào',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final amount = item['amount'] as int;
                      final iconName =
                          item['icon']?.toString() ?? 'account_balance_wallet';
                      final originalIndex = provider.transactions.indexOf(item);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _amountColor(
                              amount,
                            ).withOpacity(0.15),
                            child: Icon(
                              IconHelper.getIconData(iconName),
                              color: _amountColor(amount),
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['category']} • ${item['date']}',
                          ),
                          trailing: Text(
                            _formatAmount(amount),
                            style: TextStyle(
                              color: _amountColor(amount),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(
                                  transactionIndex: originalIndex,
                                  transaction: item,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
