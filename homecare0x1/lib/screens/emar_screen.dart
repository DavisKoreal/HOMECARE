import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class EmarScreen extends StatelessWidget {
  const EmarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eMAR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to EmarScreen'),
            const SizedBox(height: 10),
            const Text(
              'Log medication administration for a client.',
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
