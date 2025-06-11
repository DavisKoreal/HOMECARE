import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to CaregiverDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'Manage your schedule, check in/out of visits, and communicate with clients.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.scheduleOverview),
              child: const Text('View Schedule'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.visitCheckIn),
              child: const Text('Check In to Visit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.messages),
              child: const Text('Messages'),
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
