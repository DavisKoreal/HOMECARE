import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

class ScheduleOverviewScreen extends StatelessWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Overview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ScheduleOverviewScreen'),
            const SizedBox(height: 10),
            const Text(
              'View your upcoming shifts or care schedule.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, userProvider.getInitialRoute()),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
