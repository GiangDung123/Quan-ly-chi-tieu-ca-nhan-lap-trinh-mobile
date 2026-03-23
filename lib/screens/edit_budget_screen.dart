import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/icon_helper.dart';

class EditBudgetScreen extends StatefulWidget {
  final int budgetIndex;
  final String category;
  final int limitAmount;
  final int spentAmount;
  final String month;

  const EditBudgetScreen({
    super.key,
    required this.budgetIndex,
    required this.category,
    required this.limitAmount,
    required this.spentAmount,
    required this.month,
  });

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late TextEditingController _limitController;
  late TextEditingController _monthController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.limitAmount.toString(),
    );
    _monthController = TextEditingController(text: widget.month);
    _selectedCategory = widget.category;
  }

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

  Future<void> _updateBudget(
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

    await budgetProvider.updateBudget(
      index: widget.budgetIndex,
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
      SnackBar(
        content: Text('Đã cập nhật ngân sách cho ${_selectedCategory!}'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final expenseCategories = categoryProvider.expenseCategories;

    _syncSelectedCategory(expenseCategories);

    return Scaffold(
      appBar: AppBar(title: const Text('Sửa ngân sách'), centerTitle: true),
      body: expenseCategories.isEmpty
          ? const Center(
              child: Text(
                'Không có danh mục chi tiêu để sửa ngân sách',
                style: TextStyle(fontSize: 18),
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
                      'Đã chi được tự động tính từ giao dịch, không cần nhập tay.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateBudget(context, expenseCategories),
                      child: const Text(
                        'Cập nhật ngân sách',
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
