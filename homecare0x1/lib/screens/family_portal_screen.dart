import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class FamilyPortalScreen extends StatelessWidget {
  const FamilyPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Portal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to FamilyPortalScreen'),
            const SizedBox(height: 10),
            const Text(
              'Monitor care schedules, communicate, and manage payments.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.scheduleOverview),
              child: const Text('View Schedule'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.messages),
              child: const Text('Messages'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.paymentStatus),
              child: const Text('Payment Status'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
