import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class PayrollProcessingScreen extends StatelessWidget {
  const PayrollProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Processing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PayrollProcessingScreen'),
            const SizedBox(height: 10),
            const Text(
              'Calculate and process payroll for caregivers.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Billing'),
            ),
          ],
        ),
      ),
    );
  }
}
