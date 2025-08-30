import 'package:flutter/material.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showRequestShiftDialog(BuildContext context) async {
  DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? endTime = startTime.add(const Duration(hours: 2));
  String? errorMessage;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppTheme.secondaryTeal,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Caregiving Session',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Schedule a new care session',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Start Time Selection
                  _buildTimeSelectionCard(
                    context: context,
                    title: 'Start Time',
                    icon: Icons.play_arrow,
                    color: const Color(0xFF3498DB),
                    selectedTime: startTime,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startTime!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: const Color(0xFF3498DB),
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startTime!),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(
                                      primary: const Color(0xFF3498DB),
                                    ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() {
                            startTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            endTime = startTime!.add(const Duration(hours: 2));
                            errorMessage = null;
                          });
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // End Time Selection
                  _buildTimeSelectionCard(
                    context: context,
                    title: 'End Time',
                    icon: Icons.stop,
                    color: const Color(0xFFE67E22),
                    selectedTime: endTime,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endTime!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: const Color(0xFFE67E22),
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime!),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(
                                      primary: const Color(0xFFE67E22),
                                    ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          setState(() {
                            endTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            errorMessage = null;
                          });
                        }
                      }
                    },
                  ),

                  // Duration Display
                  if (startTime != null && endTime != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondaryTeal.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: AppTheme.secondaryTeal,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Duration: ${endTime!.difference(startTime!).inHours}h ${endTime!.difference(startTime!).inMinutes % 60}m',
                            style: const TextStyle(
                              color: AppTheme.secondaryTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Error Message
                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorRed.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFE9ECEF),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (startTime == null || endTime == null) {
                                setState(() {
                                  errorMessage =
                                      'Please select both start and end times';
                                });
                                return;
                              }
                              if (startTime!.isBefore(DateTime.now())) {
                                setState(() {
                                  errorMessage =
                                      'Start time must be in the future';
                                });
                                return;
                              }
                              if (startTime!.isAfter(endTime!)) {
                                setState(() {
                                  errorMessage =
                                      'Start time must be before end time';
                                });
                                return;
                              }
                              try {
                                final userProvider =
                                    Provider.of<UserProvider>(context,
                                        listen: false);
                                final shiftProvider =
                                    Provider.of<ShiftAssignmentProvider>(
                                        context,
                                        listen: false);
                                if (userProvider.user == null) {
                                  throw Exception(
                                      'User not logged in. Please log in first.');
                                }
                                await shiftProvider.requestShift(
                                  clientId: userProvider.user!.id,
                                  clientName: userProvider.user!.name,
                                  startTime: startTime!,
                                  endTime: endTime!,
                                  context: context,
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Care request submitted',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF00A86B),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              } catch (e) {
                                setState(() {
                                  errorMessage = e.toString();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.send,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
  );
}

Widget _buildTimeSelectionCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color color,
  required DateTime? selectedTime,
  required VoidCallback onTap,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedTime != null
                            ? DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(selectedTime)
                            : 'Select $title',
                        style: TextStyle(
                          color: selectedTime != null
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF7F8C8D),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}