import 'package:flutter/material.dart';
// import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';
// import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class ScheduleOverviewScreen extends StatelessWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ModernScreenLayout(
      title: 'Schedule Overview',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Schedule Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'View your upcoming shifts or care schedule.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Back to Dashboard',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, userProvider.getInitialRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
