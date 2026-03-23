import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../utils/icon_helper.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'Chi tiêu';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getCategoryIconName(String name, String type) {
    final lower = name.toLowerCase();

    if (lower.contains('ăn')) return 'restaurant';
    if (lower.contains('đi')) return 'directions_bike';
    if (lower.contains('mua')) return 'shopping_bag';
    if (lower.contains('giải')) return 'movie';
    if (lower.contains('học')) return 'school';
    if (lower.contains('nhà')) return 'home';
    if (lower.contains('lương')) return 'work';
    if (lower.contains('thưởng')) return 'card_giftcard';
    if (lower.contains('làm')) return 'attach_money';
    if (lower.contains('cho')) return 'card_giftcard';

    return type == 'Thu nhập' ? 'attach_money' : 'category';
  }

  Future<void> _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final categoryProvider = context.read<CategoryProvider>();

    if (_selectedType == 'Chi tiêu') {
      await categoryProvider.addExpenseCategory(
        name: name,
        icon: _getCategoryIconName(name, _selectedType),
      );
    } else {
      await categoryProvider.addIncomeCategory(
        name: name,
        icon: _getCategoryIconName(name, _selectedType),
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã thêm danh mục: $name')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final previewIcon = _getCategoryIconName(
      _nameController.text.trim(),
      _selectedType,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm danh mục'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'Chi tiêu', child: Text('Chi tiêu')),
                DropdownMenuItem(value: 'Thu nhập', child: Text('Thu nhập')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Loại danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Row(
                children: [
                  Icon(IconHelper.getIconData(previewIcon)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _nameController.text.trim().isEmpty
                          ? 'Biểu tượng sẽ tự động gợi ý theo tên danh mục'
                          : 'Biểu tượng được gợi ý cho danh mục này',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCategory,
                child: const Text(
                  'Lưu danh mục',
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
