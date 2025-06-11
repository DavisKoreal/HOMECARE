import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to SyncStatusScreen'),
            const SizedBox(height: 10),
            const Text(
              'View the status of data synchronization with the server.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Offline Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
