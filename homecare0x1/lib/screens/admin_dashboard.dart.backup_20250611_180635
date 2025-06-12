import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Welcome to AdminDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'Central hub for managing clients, shifts, staff, billing, and reports.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.clientList),
              child: const Text('Manage Clients'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.shiftAssignment),
              child: const Text('Assign Shifts'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.billingDashboard),
              child: const Text('View Billing'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.reportsDashboard),
              child: const Text('View Reports'),
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
