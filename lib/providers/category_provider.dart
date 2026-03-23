import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  static const String _expenseKey = 'expense_categories';
  static const String _incomeKey = 'income_categories';

  final List<Map<String, dynamic>> _expenseCategories = [];
  final List<Map<String, dynamic>> _incomeCategories = [];

  List<Map<String, dynamic>> get expenseCategories =>
      List.unmodifiable(_expenseCategories);

  List<Map<String, dynamic>> get incomeCategories =>
      List.unmodifiable(_incomeCategories);

  List<Map<String, dynamic>> get allCategories => [
    ..._expenseCategories,
    ..._incomeCategories,
  ];

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();

    final String? expenseData = prefs.getString(_expenseKey);
    final String? incomeData = prefs.getString(_incomeKey);

    _expenseCategories.clear();
    _incomeCategories.clear();

    if (expenseData != null && expenseData.isNotEmpty) {
      final List<dynamic> decodedExpense = jsonDecode(expenseData);
      for (final item in decodedExpense) {
        _expenseCategories.add(Map<String, dynamic>.from(item));
      }
    } else {
      _expenseCategories.addAll([
        {'name': 'Ăn uống', 'icon': 'restaurant'},
        {'name': 'Đi lại', 'icon': 'directions_bike'},
        {'name': 'Học tập', 'icon': 'school'},
        {'name': 'Giải trí', 'icon': 'movie'},
        {'name': 'Mua sắm', 'icon': 'shopping_bag'},
        {'name': 'Nhà ở', 'icon': 'home'},
        {'name': 'Sức khỏe', 'icon': 'health_and_safety'},
      ]);
    }

    if (incomeData != null && incomeData.isNotEmpty) {
      final List<dynamic> decodedIncome = jsonDecode(incomeData);
      for (final item in decodedIncome) {
        _incomeCategories.add(Map<String, dynamic>.from(item));
      }
    } else {
      _incomeCategories.addAll([
        {'name': 'Lương', 'icon': 'attach_money'},
        {'name': 'Làm thêm', 'icon': 'work'},
        {'name': 'Thưởng', 'icon': 'card_giftcard'},
        {'name': 'Đầu tư', 'icon': 'savings'},
        {'name': 'Khác', 'icon': 'payments'},
      ]);
    }

    await saveCategories();
    notifyListeners();
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expenseKey, jsonEncode(_expenseCategories));
    await prefs.setString(_incomeKey, jsonEncode(_incomeCategories));
  }

  Future<void> addExpenseCategory({
    required String name,
    required String icon,
  }) async {
    _expenseCategories.add({'name': name, 'icon': icon});
    await saveCategories();
    notifyListeners();
  }

  Future<void> addIncomeCategory({
    required String name,
    required String icon,
  }) async {
    _incomeCategories.add({'name': name, 'icon': icon});
    await saveCategories();
    notifyListeners();
  }

  Future<void> updateExpenseCategory({
    required int index,
    required String name,
    required String icon,
  }) async {
    _expenseCategories[index] = {'name': name, 'icon': icon};
    await saveCategories();
    notifyListeners();
  }

  Future<void> updateIncomeCategory({
    required int index,
    required String name,
    required String icon,
  }) async {
    _incomeCategories[index] = {'name': name, 'icon': icon};
    await saveCategories();
    notifyListeners();
  }

  Future<void> removeExpenseCategory(int index) async {
    _expenseCategories.removeAt(index);
    await saveCategories();
    notifyListeners();
  }

  Future<void> removeIncomeCategory(int index) async {
    _incomeCategories.removeAt(index);
    await saveCategories();
    notifyListeners();
  }
}
