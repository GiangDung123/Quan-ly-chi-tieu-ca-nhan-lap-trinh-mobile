import 'package:flutter/material.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết nhắc nhở')),
      body: const Center(child: Text('Màn hình chi tiết nhắc nhở')),
    );
  }
}
