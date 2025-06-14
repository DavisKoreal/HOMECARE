import 'package:flutter/material.dart';
// import 'package:homecare0x1/constants.dart';
// import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class EmarScreen extends StatelessWidget {
  const EmarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'eMAR',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'eMAR',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Log medication administration for a client.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Back to Check-In',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
