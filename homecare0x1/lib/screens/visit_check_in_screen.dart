import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VisitCheckInScreen extends StatefulWidget {
  final Shift? selectedShift;

  const VisitCheckInScreen({super.key, this.selectedShift});

  @override
  State<VisitCheckInScreen> createState() => _VisitCheckInScreenState();
}

class _VisitCheckInScreenState extends State<VisitCheckInScreen> {
  String? _selectedShiftId;
  Location? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final caregiverShifts = userProvider.user != null
        ? shiftProvider.getShiftsForCaregiver(userProvider.user!.id)
        : [];

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
            DropdownButtonFormField<String>(
              value: _selectedShiftId ?? widget.selectedShift?.id,
              decoration: const InputDecoration(
                labelText: 'Select Shift',
                border: OutlineInputBorder(),
              ),
              items: caregiverShifts.map((shift) {
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
              text: 'Select Random Location',
              icon: Icons.location_on,
              width: double.infinity,
              onPressed: () {
                setState(() {
                  _selectedLocation = locationProvider.getRandomLocation();
                });
              },
            ),
            if (_selectedLocation != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Selected Location: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Check In',
              icon: Icons.login,
              width: double.infinity,
              onPressed: () async {
                if (_selectedShiftId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a shift')),
                  );
                  return;
                }
                if (_selectedLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please try checking in when you have arrived at the location')),
                  );
                  return;
                }
                try {
                  await shiftProvider.updateShiftStatus(
                    shiftId: _selectedShiftId!,
                    status: 'in_session',
                    location: _selectedLocation,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checked in successfully')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
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
