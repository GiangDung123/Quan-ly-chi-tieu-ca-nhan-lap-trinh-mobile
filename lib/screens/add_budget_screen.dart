import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/icon_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _monthController = TextEditingController(
    text: '03/2026',
  );

  String? _selectedCategory;

  @override
  void dispose() {
    _limitController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _syncSelectedCategory(List<Map<String, dynamic>> categories) {
    if (categories.isEmpty) {
      _selectedCategory = null;
      return;
    }

    final exists = categories.any((item) => item['name'] == _selectedCategory);
    if (!exists) {
      _selectedCategory = categories.first['name'];
    }
  }

  String _getBudgetIconName(
    String categoryName,
    List<Map<String, dynamic>> categories,
  ) {
    final matched = categories.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['name'] == categoryName,
      orElse: () => null,
    );

    return matched?['icon'] ?? 'account_balance_wallet';
  }

  Future<void> _saveBudget(
    BuildContext context,
    List<Map<String, dynamic>> expenseCategories,
  ) async {
    if (_selectedCategory == null ||
        _limitController.text.trim().isEmpty ||
        _monthController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final limit = int.tryParse(_limitController.text.trim());

    if (limit == null || limit < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ')));
      return;
    }

    final budgetProvider = context.read<BudgetProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    await budgetProvider.addBudget(
      category: _selectedCategory!,
      limit: limit,
      month: _monthController.text.trim(),
      icon: _getBudgetIconName(_selectedCategory!, expenseCategories),
    );

    await budgetProvider.syncSpentFromTransactions(
      transactionProvider.transactions,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ngân sách cho ${_selectedCategory!}')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final expenseCategories = categoryProvider.expenseCategories;

    _syncSelectedCategory(expenseCategories);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm ngân sách'), centerTitle: true),
      body: expenseCategories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có danh mục chi tiêu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn cần tạo ít nhất một danh mục chi tiêu trước khi thêm ngân sách.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: expenseCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Row(
                          children: [
                            Icon(
                              IconHelper.getIconData(category['icon']),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giới hạn ngân sách',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _monthController,
                    decoration: const InputDecoration(
                      labelText: 'Tháng',
                      hintText: 'VD: 03/2026',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đã chi sẽ được tự động tính từ các giao dịch chi tiêu cùng danh mục.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _saveBudget(context, expenseCategories),
                      child: const Text(
                        'Lưu ngân sách',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
