import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class VisitCheckOutScreen extends StatefulWidget {
  final Shift? selectedShift;

  const VisitCheckOutScreen({super.key, this.selectedShift});

  @override
  State<VisitCheckOutScreen> createState() => _VisitCheckOutScreenState();
}

class _VisitCheckOutScreenState extends State<VisitCheckOutScreen> {
  String? _selectedShiftId;

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final caregiverShifts = userProvider.user != null
        ? shiftProvider.getShiftsForCaregiver(userProvider.user!.id)
        : [];

    return ModernScreenLayout(
      title: 'Check-Out',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Visit Check-Out',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check out of a client visit, recording end time and summary.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedShiftId ?? widget.selectedShift?.id,
              decoration: const InputDecoration(
                labelText: 'Select Shift',
                border: OutlineInputBorder(),
              ),
              items: caregiverShifts
                  .where((shift) => shift.status == 'in_session')
                  .map((shift) {
                return DropdownMenuItem<String>(
                  value: shift.id,
                  child: Text('${shift.clientName} (${DateFormat('h:mm a').format(shift.startTime)})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedShiftId = value;
                });
              },
              validator: (value) => value == null ? 'Please select a shift' : null,
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Check Out',
              icon: Icons.logout,
              width: double.infinity,
              onPressed: () async {
                if (_selectedShiftId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a shift')),
                  );
                  return;
                }
                try {
                  await shiftProvider.updateShiftStatus(
                    shiftId: _selectedShiftId!,
                    status: 'completed',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checked out successfully')),
                  );
                  Navigator.pushNamed(context, Routes.caregiverDashboard);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Dashboard',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.caregiverDashboard),
            ),
          ],
        ),
      ),
    );
  }
}
