import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'category_screen.dart';
import 'statistics_screen.dart';
import 'budget_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatMoney(int value) {
    final absValue = value.abs().toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = absValue.length - 1; i >= 0; i--) {
      buffer.write(absValue[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final recentTransactions = provider.transactions.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài chính'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xin chào!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Đây là tổng quan tài chính của bạn',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư hiện tại',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatMoney(provider.balance)} đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Thu nhập',
                    amount: '${_formatMoney(provider.totalIncome)} đ',
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Chi tiêu',
                    amount: '${_formatMoney(provider.totalExpense)} đ',
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Chức năng nhanh',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Thêm giao dịch',
                  icon: Icons.add_circle,
                  color: Colors.blue,
                  screen: const AddTransactionScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: 'Giao dịch',
                  icon: Icons.list_alt,
                  color: Colors.orange,
                  screen: const TransactionListScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: 'Danh mục',
                  icon: Icons.category,
                  color: Colors.purple,
                  screen: const CategoryScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: 'Thống kê',
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                  screen: const StatisticsScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: 'Ngân sách',
                  icon: Icons.account_balance_wallet,
                  color: Colors.indigo,
                  screen: const BudgetScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: 'Hồ sơ',
                  icon: Icons.person,
                  color: Colors.brown,
                  screen: const ProfileScreen(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recentTransactions.map(
              (item) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.attach_money)),
                  title: Text(item['title']),
                  subtitle: Text(item['date']),
                  trailing: Text(
                    _formatMoney(item['amount']),
                    style: TextStyle(
                      color: item['amount'] >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
