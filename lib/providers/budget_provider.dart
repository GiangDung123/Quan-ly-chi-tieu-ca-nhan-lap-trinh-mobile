import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  static const String _storageKey = 'budgets';

  final List<Map<String, dynamic>> _budgets = [];

  List<Map<String, dynamic>> get budgets => List.unmodifiable(_budgets);

  Future<void> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);

    _budgets.clear();

    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      for (final item in decoded) {
        _budgets.add(Map<String, dynamic>.from(item));
      }
    } else {
      _budgets.addAll([
        {
          'category': 'Ăn uống',
          'limit': 2000000,
          'spent': 0,
          'month': '03/2026',
          'icon': 'restaurant',
        },
        {
          'category': 'Đi lại',
          'limit': 500000,
          'spent': 0,
          'month': '03/2026',
          'icon': 'directions_bike',
        },
        {
          'category': 'Học tập',
          'limit': 1000000,
          'spent': 0,
          'month': '03/2026',
          'icon': 'school',
        },
        {
          'category': 'Giải trí',
          'limit': 700000,
          'spent': 0,
          'month': '03/2026',
          'icon': 'movie',
        },
      ]);
      await saveBudgets();
    }

    notifyListeners();
  }

  Future<void> saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_budgets));
  }

  Future<void> addBudget({
    required String category,
    required int limit,
    required String month,
    required String icon,
  }) async {
    _budgets.add({
      'category': category,
      'limit': limit,
      'spent': 0,
      'month': month,
      'icon': icon,
    });
    await saveBudgets();
    notifyListeners();
  }

  Future<void> updateBudget({
    required int index,
    required String category,
    required int limit,
    required String month,
    required String icon,
  }) async {
    final currentSpent = _budgets[index]['spent'] as int;

    _budgets[index] = {
      'category': category,
      'limit': limit,
      'spent': currentSpent,
      'month': month,
      'icon': icon,
    };
    await saveBudgets();
    notifyListeners();
  }

  Future<void> removeBudget(int index) async {
    _budgets.removeAt(index);
    await saveBudgets();
    notifyListeners();
  }

  Future<void> syncSpentFromTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    for (final budget in _budgets) {
      final category = budget['category'] as String;

      final spent = transactions
          .where((tx) => tx['type'] == 'Chi tiêu' && tx['category'] == category)
          .fold<int>(0, (sum, tx) => sum + (tx['amount'] as int).abs());

      budget['spent'] = spent;
    }

    await saveBudgets();
    notifyListeners();
  }

  int get totalLimit {
    return _budgets.fold(0, (sum, item) => sum + (item['limit'] as int));
  }

  int get totalSpent {
    return _budgets.fold(0, (sum, item) => sum + (item['spent'] as int));
  }

  int get totalRemain => totalLimit - totalSpent;
}
