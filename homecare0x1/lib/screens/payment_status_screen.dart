import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PaymentStatusScreen'),
            const SizedBox(height: 10),
            const Text(
              'View payment history and outstanding balances.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Family Portal'),
            ),
          ],
        ),
      ),
    );
  }
}
