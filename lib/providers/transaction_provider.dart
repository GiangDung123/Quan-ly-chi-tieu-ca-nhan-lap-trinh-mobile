import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider extends ChangeNotifier {
  static const String _storageKey = 'transactions';

  final List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> get transactions =>
      List.unmodifiable(_transactions);

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);

    _transactions.clear();

    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);

      for (final item in decoded) {
        final map = Map<String, dynamic>.from(item);

        _transactions.add({
          'title': map['title']?.toString() ?? '',
          'amount': (map['amount'] as num?)?.toInt() ?? 0,
          'type': map['type']?.toString() ?? 'Chi tiêu',
          'category': map['category']?.toString() ?? '',
          'date': map['date']?.toString() ?? '',
          'note': map['note']?.toString() ?? '',
          'icon': map['icon']?.toString() ?? 'account_balance_wallet',
        });
      }
    } else {
      _transactions.addAll([
        {
          'title': 'Ăn sáng',
          'amount': -30000,
          'type': 'Chi tiêu',
          'category': 'Ăn uống',
          'date': '20/03/2026',
          'note': 'Bánh mì và sữa',
          'icon': 'restaurant',
        },
        {
          'title': 'Lương part-time',
          'amount': 2500000,
          'type': 'Thu nhập',
          'category': 'Làm thêm',
          'date': '18/03/2026',
          'note': 'Lương tháng này',
          'icon': 'attach_money',
        },
        {
          'title': 'Đổ xăng',
          'amount': -100000,
          'type': 'Chi tiêu',
          'category': 'Đi lại',
          'date': '17/03/2026',
          'note': 'Xe máy',
          'icon': 'directions_bike',
        },
      ]);
      await saveTransactions();
    }

    notifyListeners();
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_transactions));
  }

  Future<void> addTransaction({
    required String title,
    required int amount,
    required String type,
    required String category,
    required String date,
    required String note,
    required String icon,
  }) async {
    _transactions.insert(0, {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
      'icon': icon,
    });

    await saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction({
    required int index,
    required String title,
    required int amount,
    required String type,
    required String category,
    required String date,
    required String note,
    required String icon,
  }) async {
    if (index < 0 || index >= _transactions.length) return;

    _transactions[index] = {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
      'icon': icon,
    };

    await saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(int index) async {
    if (index < 0 || index >= _transactions.length) return;

    _transactions.removeAt(index);
    await saveTransactions();
    notifyListeners();
  }

  Future<void> clearAllTransactions() async {
    _transactions.clear();
    await saveTransactions();
    notifyListeners();
  }

  int get totalIncome {
    return _transactions
        .where((item) => ((item['amount'] as num?)?.toInt() ?? 0) > 0)
        .fold(0, (sum, item) => sum + ((item['amount'] as num?)?.toInt() ?? 0));
  }

  int get totalExpense {
    return _transactions
        .where((item) => ((item['amount'] as num?)?.toInt() ?? 0) < 0)
        .fold(
          0,
          (sum, item) => sum + (((item['amount'] as num?)?.toInt() ?? 0).abs()),
        );
  }

  int get balance => totalIncome - totalExpense;
}
