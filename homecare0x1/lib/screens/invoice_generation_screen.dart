import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class InvoiceGenerationScreen extends StatelessWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to InvoiceGenerationScreen'),
            const SizedBox(height: 10),
            const Text(
              'Create and send invoices to clients for services rendered.',
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
