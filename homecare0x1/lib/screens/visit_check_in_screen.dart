import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class VisitCheckInScreen extends StatelessWidget {
  const VisitCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Check-In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to VisitCheckInScreen'),
            const SizedBox(height: 10),
            const Text(
              'Check in to a client visit, recording start time and location.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.taskList),
              child: const Text('View Tasks'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.emar),
              child: const Text('Log Medication'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.careNotes),
              child: const Text('Add Care Notes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.visitCheckOut),
              child: const Text('Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}
