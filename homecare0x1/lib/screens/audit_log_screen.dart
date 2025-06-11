import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to AuditLogScreen'),
            const SizedBox(height: 10),
            const Text(
              'View a log of system actions for compliance and auditing.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
