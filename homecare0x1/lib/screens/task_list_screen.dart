import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TaskListScreen'),
            const SizedBox(height: 10),
            const Text(
              'View and complete tasks for a specific client visit.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
