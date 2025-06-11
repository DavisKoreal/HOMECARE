import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class VisitCheckOutScreen extends StatelessWidget {
  const VisitCheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Check-Out')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to VisitCheckOutScreen'),
            const SizedBox(height: 10),
            const Text(
              'Check out of a client visit, recording end time and summary.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.caregiverDashboard),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
