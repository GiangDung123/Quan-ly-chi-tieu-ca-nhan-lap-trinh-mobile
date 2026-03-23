import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../utils/icon_helper.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedType = 'Tất cả';

  final List<String> _filters = ['Tất cả', 'Chi tiêu', 'Thu nhập'];

  Color _getTypeColor(String type) {
    return type == 'Thu nhập' ? Colors.green : Colors.red;
  }

  Future<void> _showDeleteDialog({
    required int index,
    required String name,
    required String type,
  }) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa danh mục'),
          content: Text('Bạn có chắc muốn xóa danh mục "$name" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<CategoryProvider>();

                if (type == 'Chi tiêu') {
                  await provider.removeExpenseCategory(index);
                } else {
                  await provider.removeIncomeCategory(index);
                }

                if (!context.mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa danh mục: $name')),
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    final expenseCategories = provider.expenseCategories
        .map(
          (item) => {
            ...item,
            'type': 'Chi tiêu',
            'originalIndex': provider.expenseCategories.indexOf(item),
          },
        )
        .toList();

    final incomeCategories = provider.incomeCategories
        .map(
          (item) => {
            ...item,
            'type': 'Thu nhập',
            'originalIndex': provider.incomeCategories.indexOf(item),
          },
        )
        .toList();

    final allCategories = [...expenseCategories, ...incomeCategories];

    final categories = _selectedType == 'Tất cả'
        ? allCategories
        : allCategories.where((item) => item['type'] == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
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
                  'Quản lý danh mục giao dịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tổng số danh mục: ${allCategories.length}',
                  style: const TextStyle(fontSize: 15),
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
                final isSelected = filter == _selectedType;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Text(
                      'Không có danh mục nào',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final typeColor = _getTypeColor(item['type']);
                      final originalIndex = item['originalIndex'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: typeColor.withOpacity(0.12),
                            child: Icon(
                              IconHelper.getIconData(item['icon']),
                              color: typeColor,
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(item['type']),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditCategoryScreen(
                                      categoryIndex: originalIndex,
                                      categoryName: item['name'],
                                      categoryType: item['type'],
                                      categoryIcon: item['icon'],
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                _showDeleteDialog(
                                  index: originalIndex,
                                  name: item['name'],
                                  type: item['type'],
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Sửa')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
