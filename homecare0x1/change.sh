#!/bin/bash

# update_visit_check_in.sh: Updates VisitCheckInScreen UI to match other pages
# Run from project root (homecare0x1). Updates lib/screens/visit_check_in_screen.dart.
# Uses Git for backups (git add . and git commit).

# Ensure script is executable
chmod +x "$0"

# Update lib/screens/visit_check_in_screen.dart
cat << 'EOF' > lib/screens/visit_check_in_screen.dart
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

class _VisitCheckInScreenState extends State<VisitCheckInScreen> with SingleTickerProviderStateMixin {
  String? _selectedShiftId;
  Location? _selectedLocation;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      showBackButton: true,
      onBackPressed: () => Navigator.pushNamed(context, Routes.caregiverDashboard),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visit Check-In',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check in to a client visit, recording start time and location.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (caregiverShifts.isEmpty)
                        Text(
                          'No shifts assigned',
                          style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedShiftId ?? widget.selectedShift?.id,
                          decoration: InputDecoration(
                            labelText: 'Select Shift',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppTheme.primaryBlue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                            ),
                          ),
                          items: caregiverShifts.map((shift) {
                            return DropdownMenuItem<String>(
                              value: shift.id,
                              child: Text(
                                '${shift.clientName} (${DateFormat('h:mm a').format(shift.startTime)})',
                                style: TextStyle(color: AppTheme.primaryBlue),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedShiftId = value;
                            });
                          },
                          validator: (value) => value == null && caregiverShifts.isNotEmpty
                              ? 'Please select a shift'
                              : null,
                        ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Select Random Location',
                        icon: Icons.location_on,
                        width: double.infinity,
                        backgroundColor: AppTheme.primaryBlue,
                        textColor: Colors.white,
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryBlue,
                                ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Check In',
                        icon: Icons.login,
                        width: double.infinity,
                        backgroundColor: AppTheme.primaryBlue,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (_selectedShiftId == null && caregiverShifts.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a shift',
                                  style: TextStyle(color: AppTheme.accentOrange),
                                ),
                              ),
                            );
                            return;
                          }
                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please try checking in when you have arrived at the location',
                                  style: TextStyle(color: AppTheme.accentOrange),
                                ),
                              ),
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
                              SnackBar(
                                content: Text(
                                  'Error: $e',
                                  style: TextStyle(color: AppTheme.accentOrange),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'View Tasks',
                        icon: Icons.task,
                        width: double.infinity,
                        backgroundColor: AppTheme.primaryBlue,
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(context, Routes.taskList),
                      ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Log Medication',
                        icon: Icons.medical_services,
                        width: double.infinity,
                        backgroundColor: AppTheme.primaryBlue,
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(context, Routes.emar),
                      ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Add Care Notes',
                        icon: Icons.note,
                        width: double.infinity,
                        backgroundColor: AppTheme.primaryBlue,
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(context, Routes.careNotes),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# Stage and commit changes with Git
git add .
git commit -m "Update VisitCheckInScreen UI to match other pages with ModernButton and Card"

echo "Script completed. Updated file:"
echo "- lib/screens/visit_check_in_screen.dart"
echo "Changes staged and committed with Git."
echo "Verify changes with 'git status' and test with 'flutter run'."
echo "Revert changes if needed with 'git reset --hard'."