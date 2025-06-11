import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class CareNotesScreen extends StatelessWidget {
  const CareNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care Notes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to CareNotesScreen'),
            const SizedBox(height: 10),
            const Text(
              'Record notes about a client\'s condition or visit.',
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
