import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  final Map<DateTime, List<Shift>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadEvents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    final provider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
    _events.clear();
    for (final shift in provider.allShifts) {
      final day = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(shift);
    }
  }

  List<Shift> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _showAddShiftDialog() async {
    final clientIdController = TextEditingController();
    final clientNameController = TextEditingController();
    DateTime? startTime = _selectedDay;
    DateTime? endTime = _selectedDay?.add(const Duration(hours: 2));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Shift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Select Start Time',
                icon: Icons.access_time,
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && startTime != null) {
                    startTime = DateTime(
                      startTime!.year,
                      startTime!.month,
                      startTime!.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Select End Time',
                icon: Icons.access_time,
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && endTime != null) {
                    endTime = DateTime(
                      endTime!.year,
                      endTime!.month,
                      endTime!.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Add Shift',
            icon: Icons.add,
            onPressed: () async {
              if (clientIdController.text.isNotEmpty &&
                  clientNameController.text.isNotEmpty &&
                  startTime != null &&
                  endTime != null) {
                try {
                  await Provider.of<ShiftAssignmentProvider>(context, listen: false)
                      .addShift(
                    clientId: clientIdController.text,
                    clientName: clientNameController.text,
                    startTime: startTime!,
                    endTime: endTime!,
                    context: context,
                  );
                  Navigator.pop(context);
                  setState(() => _loadEvents());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shift added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditShiftDialog(Shift shift) async {
    DateTime? startTime = shift.startTime;
    DateTime? endTime = shift.endTime;
    String? selectedCaregiverId = shift.caregiverId;
    String? selectedCaregiverName = shift.caregiverName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Shift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client: ${shift.clientName}'),
              const SizedBox(height: 16),
              Consumer<ShiftAssignmentProvider>(
                builder: (context, provider, child) {
                  final caregivers = provider.availableCaregivers;
                  return DropdownButtonFormField<String>(
                    value: selectedCaregiverId,
                    decoration: const InputDecoration(
                      labelText: 'Caregiver (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...caregivers.map((caregiver) => DropdownMenuItem<String>(
                            value: caregiver.id,
                            child: Text(caregiver.name),
                          )),
                    ],
                    onChanged: (value) {
                      selectedCaregiverId = value;
                      selectedCaregiverName = value != null
                          ? caregivers.firstWhere((c) => c.id == value).name
                          : null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Select Start Time',
                icon: Icons.access_time,
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(shift.startTime),
                  );
                  if (time != null) {
                    startTime = DateTime(
                      shift.startTime.year,
                      shift.startTime.month,
                      shift.startTime.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Select End Time',
                icon: Icons.access_time,
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(shift.endTime),
                  );
                  if (time != null) {
                    endTime = DateTime(
                      shift.endTime.year,
                      shift.endTime.month,
                      shift.endTime.day,
                      time.hour,
                      time.minute,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Save Changes',
            icon: Icons.save,
            onPressed: () async {
              if (startTime != null && endTime != null) {
                try {
                  await Provider.of<ShiftAssignmentProvider>(context, listen: false)
                      .updateShift(
                    shiftId: shift.id,
                    startTime: startTime!,
                    endTime: endTime!,
                    context: context,
                    caregiverId: selectedCaregiverId,
                    caregiverName: selectedCaregiverName,
                  );
                  Navigator.pop(context);
                  setState(() => _loadEvents());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shift updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ModernScreenLayout(
      title: 'Admin Calendar',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  Navigator.pushNamed(
                    context,
                    Routes.shiftList,
                    arguments: selectedDay,
                  );
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Add New Shift',
                icon: Icons.add,
                width: double.infinity,
                onPressed: _showAddShiftDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
