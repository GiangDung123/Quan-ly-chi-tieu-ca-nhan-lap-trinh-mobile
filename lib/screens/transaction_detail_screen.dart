import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/icon_helper.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final int transactionIndex;
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transactionIndex,
    required this.transaction,
  });

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
    return '${amount < 0 ? '-' : '+'}$result đ';
  }

  @override
  Widget build(BuildContext context) {
    final int amount = transaction['amount'] as int;
    final bool isExpense = amount < 0;
    final String iconName =
        transaction['icon']?.toString() ?? 'account_balance_wallet';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTransactionScreen(
                    transactionIndex: transactionIndex,
                    transaction: transaction,
                  ),
                ),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isExpense
                    ? Colors.red.withOpacity(0.08)
                    : Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Icon(IconHelper.getIconData(iconName), size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transaction['title'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatAmount(amount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile(
              icon: Icons.swap_horiz,
              title: 'Loại giao dịch',
              value: transaction['type'] ?? '',
            ),
            _buildInfoTile(
              icon: Icons.category,
              title: 'Danh mục',
              value: transaction['category'] ?? '',
            ),
            _buildInfoTile(
              icon: Icons.calendar_today,
              title: 'Ngày',
              value: transaction['date'] ?? '',
            ),
            _buildInfoTile(
              icon: Icons.note,
              title: 'Ghi chú',
              value:
                  (transaction['note'] == null ||
                      transaction['note'].toString().trim().isEmpty)
                  ? 'Không có ghi chú'
                  : transaction['note'].toString(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTransactionScreen(
                        transactionIndex: transactionIndex,
                        transaction: transaction,
                      ),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Chỉnh sửa giao dịch',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final transactionProvider = context.read<TransactionProvider>();
              final budgetProvider = context.read<BudgetProvider>();

              await transactionProvider.removeTransaction(transactionIndex);
              await budgetProvider.syncSpentFromTransactions(
                transactionProvider.transactions,
              );

              if (!context.mounted) return;

              Navigator.pop(dialogContext);
              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã xóa giao dịch')));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
