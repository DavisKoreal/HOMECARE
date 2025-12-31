import 'package:flutter/material.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, List<Shift>> _events = {};
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final provider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
      await provider.fetchShifts();
      
      if (mounted) {
        setState(() {
          _events.clear();
          for (final shift in provider.allShifts) {
            final day = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);
            _events[day] ??= [];
            _events[day]!.add(shift);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Shift> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              // We can add "Week/Day" toggles here in future
            ],
          ),
          const SizedBox(height: 24),

          // Calendar Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: _isLoading 
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              : TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  
                  // Styles
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppTheme.textSecondary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  },
                ),
          ),

          const SizedBox(height: 24),

          // Events List for Selected Day
          if (_selectedDay != null) ...[
            Text(
              'Shifts for ${_selectedDay!.month}/${_selectedDay!.day}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            ..._getEventsForDay(_selectedDay!).map((shift) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shift.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${shift.startTime.hour}:${shift.startTime.minute.toString().padLeft(2, '0')} - ${shift.endTime.hour}:${shift.endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(shift.status, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: AppTheme.getStatusColor(shift.status),
                    padding: EdgeInsets.zero,
                  )
                ],
              ),
            )).toList(),
            
            if (_getEventsForDay(_selectedDay!).isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No shifts scheduled for this day.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
          ],
        ],
      ),
    );
  }
}
