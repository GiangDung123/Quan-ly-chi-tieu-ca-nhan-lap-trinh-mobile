import 'package:flutter/material.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách nhắc nhở')),
      body: const Center(child: Text('Màn hình danh sách nhắc nhở')),
    );
  }
}
