import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/icon_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final int transactionIndex;
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({
    super.key,
    required this.transactionIndex,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedType;
  String? _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _types = ['Chi tiêu', 'Thu nhập'];

  @override
  void initState() {
    super.initState();

    final int oldAmount = widget.transaction['amount'] as int;

    _titleController = TextEditingController(
      text: widget.transaction['title'] ?? '',
    );
    _amountController = TextEditingController(text: oldAmount.abs().toString());
    _noteController = TextEditingController(
      text: widget.transaction['note'] ?? '',
    );

    _selectedType = widget.transaction['type'] ?? 'Chi tiêu';
    _selectedCategory = widget.transaction['category']?.toString();
    _selectedDate = _parseDate(widget.transaction['date']?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  List<Map<String, dynamic>> _getCurrentCategories(
    CategoryProvider categoryProvider,
  ) {
    return _selectedType == 'Chi tiêu'
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;
  }

  void _syncSelectedCategory(List<Map<String, dynamic>> categories) {
    if (categories.isEmpty) {
      _selectedCategory = null;
      return;
    }

    final exists = categories.any((item) => item['name'] == _selectedCategory);
    if (!exists) {
      _selectedCategory = categories.first['name']?.toString();
    }
  }

  String _getCategoryIconName(
    String categoryName,
    List<Map<String, dynamic>> categories,
  ) {
    final matched = categories.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['name'] == categoryName,
      orElse: () => null,
    );

    return matched?['icon']?.toString() ?? 'account_balance_wallet';
  }

  Future<void> _updateTransaction(
    BuildContext context,
    List<Map<String, dynamic>> currentCategories,
  ) async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text.trim());
      final note = _noteController.text.trim();
      final title = _titleController.text.trim();

      final realAmount = _selectedType == 'Chi tiêu' ? -amount : amount;

      final transactionProvider = context.read<TransactionProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      await transactionProvider.updateTransaction(
        index: widget.transactionIndex,
        title: title,
        amount: realAmount,
        type: _selectedType,
        category: _selectedCategory!,
        date: _formatDate(_selectedDate),
        note: note,
        icon: _getCategoryIconName(_selectedCategory!, currentCategories),
      );

      await budgetProvider.syncSpentFromTransactions(
        transactionProvider.transactions,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật giao dịch thành công')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final currentCategories = _getCurrentCategories(categoryProvider);

    _syncSelectedCategory(currentCategories);

    return Scaffold(
      appBar: AppBar(title: const Text('Sửa giao dịch'), centerTitle: true),
      body: currentCategories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có danh mục phù hợp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hiện chưa có danh mục cho loại "$_selectedType". Hãy tạo danh mục trước.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: Ăn trưa, Lương tháng',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên giao dịch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loại giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _types.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedType = value;
                          final updatedCategories = _getCurrentCategories(
                            categoryProvider,
                          );
                          _selectedCategory = updatedCategories.isNotEmpty
                              ? updatedCategories.first['name']?.toString()
                              : null;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Số tiền',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Nhập số tiền',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số tiền';
                        }
                        final number = int.tryParse(value.trim());
                        if (number == null || number <= 0) {
                          return 'Số tiền không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: currentCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['name']?.toString(),
                          child: Row(
                            children: [
                              Icon(
                                IconHelper.getIconData(
                                  category['icon']?.toString() ??
                                      'account_balance_wallet',
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(category['name']?.toString() ?? ''),
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
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ngày giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ghi chú',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nhập ghi chú',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateTransaction(context, currentCategories),
                        child: const Text(
                          'Cập nhật giao dịch',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
