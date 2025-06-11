import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ClientProfileScreen'),
            const SizedBox(height: 10),
            const Text(
              'View and edit detailed client information, including care plans.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Client List'),
            ),
          ],
        ),
      ),
    );
  }
}
