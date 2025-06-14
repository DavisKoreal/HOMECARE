import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ModernScreenLayout(
      title: 'User Profile',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'View and edit your profile details (e.g., name, email, contact info).',
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
