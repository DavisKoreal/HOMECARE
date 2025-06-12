import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class VisitCheckInScreen extends StatelessWidget {
  const VisitCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Check-In',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Visit Check-In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check in to a client visit, recording start time and location.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'View Tasks',
              icon: Icons.task,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.taskList),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Log Medication',
              icon: Icons.medical_services,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.emar),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Add Care Notes',
              icon: Icons.note,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.careNotes),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Check Out',
              icon: Icons.check_outlined,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.visitCheckOut),
            ),
          ],
        ),
      ),
    );
  }
}
