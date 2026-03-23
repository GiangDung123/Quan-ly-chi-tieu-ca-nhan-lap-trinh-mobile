import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../utils/icon_helper.dart';

class EditCategoryScreen extends StatefulWidget {
  final int categoryIndex;
  final String categoryName;
  final String categoryType;
  final String categoryIcon;

  const EditCategoryScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryName,
    required this.categoryType,
    required this.categoryIcon,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryName);
    _selectedType = widget.categoryType;
  }

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
    if (lower.contains('thưởng')) return 'emoji_events';
    if (lower.contains('làm')) return 'attach_money';
    if (lower.contains('cho')) return 'card_giftcard';

    return type == 'Thu nhập' ? 'trending_up' : 'category';
  }

  Future<void> _updateCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final provider = context.read<CategoryProvider>();

    if (_selectedType == 'Chi tiêu') {
      await provider.updateExpenseCategory(
        index: widget.categoryIndex,
        name: name,
        icon: _getCategoryIconName(name, _selectedType),
      );
    } else {
      await provider.updateIncomeCategory(
        index: widget.categoryIndex,
        name: name,
        icon: _getCategoryIconName(name, _selectedType),
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã cập nhật danh mục: $name')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final previewIcon = _getCategoryIconName(
      _nameController.text.trim().isEmpty
          ? widget.categoryName
          : _nameController.text.trim(),
      _selectedType,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sửa danh mục'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(IconHelper.getIconData(previewIcon), size: 30),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateCategory,
                child: const Text(
                  'Cập nhật danh mục',
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
