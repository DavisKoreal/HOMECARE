import os

def refactor_complex_screens():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Refactor Admin Initiate Shift (New Shift)
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_initiate_shift.dart ---")
    shift_path = os.path.join("lib", "screens", "admin_initiate_shift.dart")
    
    shift_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminInitiateShift extends StatefulWidget {
  const AdminInitiateShift({super.key});

  @override
  State<AdminInitiateShift> createState() => _AdminInitiateShiftState();
}

class _AdminInitiateShiftState extends State<AdminInitiateShift> {
  // Data
  List<Client> _clients = [];
  List<CaregiverProfile> _caregivers = [];
  
  // Selection
  String? _selectedClientId;
  String? _selectedClientName;
  String? _selectedCaregiverId;
  String? _selectedCaregiverName;
  
  // Form State
  DateTime? _startTime;
  DateTime? _endTime;
  bool _broadcast = false;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await FirebaseShiftService.instance.getAllClients();
      final caregivers = await FirebaseCaregiverService.instance.getAllCaregiverProfiles();
      if (mounted) {
        setState(() {
          _clients = clients;
          _caregivers = caregivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startTime = dt;
        // Auto-set end time to 8 hours later if not set
        if (_endTime == null) {
          _endTime = dt.add(const Duration(hours: 8));
        }
      } else {
        _endTime = dt;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedClientId == null) {
      _showError('Please select a client');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Please set start and end times');
      return;
    }
    if (!_broadcast && _selectedCaregiverId == null) {
      _showError('Please select a caregiver or enable broadcast');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseShiftService.instance.addShift(
        clientId: _selectedClientId!,
        clientName: _selectedClientName!,
        startTime: _startTime!,
        endTime: _endTime!,
        context: context,
        caregiverId: _selectedCaregiverId,
        caregiverName: _selectedCaregiverName,
        broadcast: _broadcast,
        adminNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift created successfully'), backgroundColor: AppTheme.successGreen),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Single Page Form Layout
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create New Shift',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Assign a caregiver to a client for a specific time block.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Divider(height: 48),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else ...[
                // 1. Client Selection
                _buildLabel('Client Recipient'),
                DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  hint: const Text('Select Client'),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: _clients.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClientId = val;
                      _selectedClientName = _clients.firstWhere((c) => c.id == val).name;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 2. Time Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Time'),
                          InkWell(
                            onTap: () => _selectDateTime(true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderGray),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    _startTime != null 
                                      ? DateFormat('MMM d, h:mm a').format(_startTime!) 
                                      : 'Select Start',
                                    style: TextStyle(
                                      color: _startTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Time'),
                          InkWell(
                            onTap: () => _selectDateTime(false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderGray),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    _endTime != null 
                                      ? DateFormat('MMM d, h:mm a').format(_endTime!) 
                                      : 'Select End',
                                    style: TextStyle(
                                      color: _endTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Caregiver Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Caregiver Assignment'),
                    Row(
                      children: [
                        Checkbox(
                          value: _broadcast, 
                          activeColor: AppTheme.primaryPurple,
                          onChanged: (val) => setState(() {
                            _broadcast = val!;
                            if (val) {
                              _selectedCaregiverId = null;
                              _selectedCaregiverName = null;
                            }
                          }),
                        ),
                        const Text('Broadcast to all available'),
                      ],
                    ),
                  ],
                ),
                if (!_broadcast)
                  DropdownButtonFormField<String>(
                    value: _selectedCaregiverId,
                    hint: const Text('Select Caregiver'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _caregivers.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} (${c.role})'),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCaregiverId = val;
                        _selectedCaregiverName = _caregivers.firstWhere((c) => c.id == val).name;
                      });
                    },
                  ),
                
                const SizedBox(height: 24),

                // 4. Notes
                _buildLabel('Notes (Optional)'),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter specific instructions for this shift...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Publish Shift'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}
"""
    with open(shift_path, "w", encoding="utf-8") as f:
        f.write(shift_content)
    print("Rewrote admin_initiate_shift.dart")


    # ---------------------------------------------------------
    # 2. Refactor Admin Caregiver Approval
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_caregiver_approval.dart ---")
    approval_path = os.path.join("lib", "screens", "admin_caregiver_approval.dart")
    
    approval_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class AdminCaregiverApprovalPage extends StatefulWidget {
  final String adminId;

  const AdminCaregiverApprovalPage({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  State<AdminCaregiverApprovalPage> createState() => _AdminCaregiverApprovalPageState();
}

class _AdminCaregiverApprovalPageState extends State<AdminCaregiverApprovalPage> {
  final FirebaseCaregiverService _service = FirebaseCaregiverService.instance;
  List<CaregiverProfile> _unapprovedCaregivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnapprovedCaregivers();
  }

  Future<void> _loadUnapprovedCaregivers() async {
    setState(() => _isLoading = true);
    final caregivers = await _service.getUnApprovedCaregivers();
    if (mounted) {
      setState(() {
        _unapprovedCaregivers = caregivers;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(CaregiverProfile caregiver) async {
    setState(() => _isLoading = true);
    final result = await _service.upsertApprovalStatus(
      caregiver.id,
      true,
      widget.adminId,
    );
    
    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${caregiver.name} approved'), backgroundColor: AppTheme.successGreen)
      );
      await _loadUnapprovedCaregivers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve'), backgroundColor: AppTheme.errorRed)
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Approvals',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review and approve new caregiver registrations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUnapprovedCaregivers,
                tooltip: 'Refresh List',
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (_unapprovedCaregivers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successGreen),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('There are no pending approvals at this time.', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unapprovedCaregivers.length,
              itemBuilder: (context, index) {
                final c = _unapprovedCaregivers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(c.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.role, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(c.phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _approve(c),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
"""
    with open(approval_path, "w", encoding="utf-8") as f:
        f.write(approval_content)
    print("Rewrote admin_caregiver_approval.dart")


    # ---------------------------------------------------------
    # 3. Refactor Admin Calendar
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_calendar_screen.dart ---")
    calendar_path = os.path.join("lib", "screens", "admin_calendar_screen.dart")
    
    calendar_content = """import 'package:flutter/material.dart';
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
"""
    with open(calendar_path, "w", encoding="utf-8") as f:
        f.write(calendar_content)
    print("Rewrote admin_calendar_screen.dart")

if __name__ == "__main__":
    refactor_complex_screens()