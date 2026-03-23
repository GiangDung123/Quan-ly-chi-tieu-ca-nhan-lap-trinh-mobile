import 'package:flutter/material.dart';

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhắc nhở')),
      body: const Center(child: Text('Màn hình thêm nhắc nhở')),
    );
  }
}
