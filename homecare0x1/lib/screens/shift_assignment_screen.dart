import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShiftAssignmentScreen extends StatelessWidget {
  const ShiftAssignmentScreen({super.key});

  void _assignCaregiver(BuildContext context, Shift shift) {
    final provider =
        Provider.of<ShiftAssignmentProvider>(context, listen: false);
    final availableCaregivers = provider.availableCaregivers;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Caregiver for ${shift.clientName}'),
        content: availableCaregivers.isEmpty
            ? const Text('No available caregivers.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableCaregivers.map((caregiver) {
                    return ListTile(
                      title: Text(caregiver.name),
                      onTap: () {
                        provider.assignShift(
                          shift.id,
                          caregiver.id,
                          caregiver.name,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Assigned ${caregiver.name} to ${shift.clientName}\'s shift.',
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShiftAssignmentProvider>(context);
    final unassignedShifts = provider.unassignedShifts;
    final availableCaregivers = provider.availableCaregivers;

    return ModernScreenLayout(
      title: 'Shift Assignment',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Shifts',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Match caregivers to unassigned client shifts.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Available Caregivers (${availableCaregivers.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            availableCaregivers.isEmpty
                ? const Center(child: Text('No caregivers available'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableCaregivers.length,
                    itemBuilder: (context, index) {
                      final caregiver = availableCaregivers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(caregiver.name),
                          leading: Icon(
                            Icons.person,
                            color: AppTheme.primaryBlue,
                          ),
                          subtitle: const Text('Available'),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Text(
              'Unassigned Shifts (${unassignedShifts.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            unassignedShifts.isEmpty
                ? const Center(child: Text('No unassigned shifts'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unassignedShifts.length,
                    itemBuilder: (context, index) {
                      final shift = unassignedShifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(shift.clientName),
                          subtitle: Text(
                            'Date: ${DateFormat('MMM d, h:mm a').format(shift.dateTime)}',
                          ),
                          leading: Icon(
                            Icons.event,
                            color: AppTheme.primaryBlue,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _assignCaregiver(context, shift),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
