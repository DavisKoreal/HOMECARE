import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:homecare0x1/models/shift.dart';

class CaregiverCalendarScreen extends StatefulWidget {
  const CaregiverCalendarScreen({super.key});

  @override
  State<CaregiverCalendarScreen> createState() => _CaregiverCalendarScreenState();
}

class _CaregiverCalendarScreenState extends State<CaregiverCalendarScreen>
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
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _events.clear();
    if (user != null) {
      final shifts = provider.getShiftsForCaregiver(user.id);
      for (final shift in shifts) {
        final day = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);
        if (_events[day] == null) {
          _events[day] = [];
        }
        _events[day]!.add(shift);
      }
    }
  }

  List<Shift> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ModernScreenLayout(
      title: 'Caregiver Calendar',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.caregiverDashboard),
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
              Text(
                'Shifts on ${DateFormat('MMMM d, yyyy').format(_selectedDay ?? _focusedDay)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<ShiftAssignmentProvider>(
                builder: (context, provider, child) {
                  final shifts = _getEventsForDay(_selectedDay ?? _focusedDay);
                  if (shifts.isEmpty) {
                    return const Center(child: Text('No shifts scheduled'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shifts.length,
                    itemBuilder: (context, index) {
                      final shift = shifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                            child: Icon(Icons.event, color: AppTheme.primaryBlue),
                          ),
                          title: Text(shift.clientName),
                          subtitle: Text(
                            '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}\n'
                            'Status: ${shift.status}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (shift.status == 'pending')
                                ModernButton(
                                  text: 'Check In',
                                  icon: Icons.login,
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    Routes.visitCheckIn,
                                    arguments: shift,
                                  ),
                                ),
                              if (shift.status == 'in_session')
                                ModernButton(
                                  text: 'Check Out',
                                  icon: Icons.logout,
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    Routes.visitCheckOut,
                                    arguments: shift,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
