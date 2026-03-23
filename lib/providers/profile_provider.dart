import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _storageKey = 'user_profile';

  Map<String, dynamic> _profile = {
    'name': 'Giàng A Dụng',
    'email': 'giangadung@example.com',
    'phone': '0123 456 789',
    'job': 'Sinh viên',
    'bio': 'Quản lý tài chính cá nhân',
    'avatarUrl': '',
  };

  Map<String, dynamic> get profile => Map.unmodifiable(_profile);

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null && data.isNotEmpty) {
      _profile = Map<String, dynamic>.from(jsonDecode(data));
      _profile.putIfAbsent('avatarUrl', () => '');
    } else {
      await saveProfile(
        name: _profile['name'],
        email: _profile['email'],
        phone: _profile['phone'],
        job: _profile['job'],
        bio: _profile['bio'],
        avatarUrl: _profile['avatarUrl'],
        notify: false,
      );
    }

    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String job,
    required String bio,
    required String avatarUrl,
    bool notify = true,
  }) async {
    _profile = {
      'name': name,
      'email': email,
      'phone': phone,
      'job': job,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profile));

    if (notify) {
      notifyListeners();
    }
  }
}
