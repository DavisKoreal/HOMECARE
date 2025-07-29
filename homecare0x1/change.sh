#!/bin/bash

# update_scheduler.sh: Implements timekeeping feature for homecare0x1
# Run from project root. Updates and creates files for shift scheduling.
# Uses Git for backups (git add . and git commit).

# Ensure script is executable
chmod +x "$0"

# Check dependencies in pubspec.yaml
check_dependencies() {
    if ! grep -q "provider:" pubspec.yaml; then
        echo "Warning: 'provider' dependency missing in pubspec.yaml. Add:"
        echo "  provider: ^6.0.5"
    fi
    if ! grep -q "intl:" pubspec.yaml; then
        echo "Warning: 'intl' dependency missing in pubspec.yaml. Add:"
        echo "  intl: ^0.19.0"
    fi
}

# 1. Update lib/providers/shift_assignment_provider.dart
cat << 'EOF' > lib/providers/shift_assignment_provider.dart
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Location {
  double latitude;
  double longitude;

  Location({required this.latitude, required this.longitude});
}

class Shift {
  final String id;
  final String clientId;
  String clientName;
  DateTime startTime;
  DateTime endTime;
  String? caregiverId;
  String? caregiverName;
  String status;
  Location? location;

  Shift({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.startTime,
    required this.endTime,
    this.caregiverId,
    this.caregiverName,
    required this.status,
    this.location,
  });
}

class Caregiver {
  final String id;
  final String name;
  final bool isAvailable;

  Caregiver({
    required this.id,
    required this.name,
    required this.isAvailable,
  });
}

class ShiftAssignmentProvider with ChangeNotifier {
  final List<Caregiver> _caregivers = [
    Caregiver(id: 'cg1', name: 'Emma Wilson', isAvailable: true),
    Caregiver(id: 'cg2', name: 'Liam Brown', isAvailable: true),
    Caregiver(id: 'cg3', name: 'Olivia Davis', isAvailable: false),
    Caregiver(id: 'cg4', name: 'Noah Taylor', isAvailable: true),
  ];

  final List<Client> _clients = [
    Client(
      id: 'c1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      address: '123 Elm St, Springfield',
      carePlan: 'Daily care',
    ),
    Client(
      id: 'c2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      address: '456 Oak Ave, Springfield',
      carePlan: 'Weekly check-in',
    ),
    Client(
      id: 'c3',
      name: 'Alice Johnson',
      email: 'alice.johnson@example.com',
      address: '789 Pine Rd, Springfield',
      carePlan: 'Post-op care',
    ),
    Client(
      id: 'c4',
      name: 'Bob Wilson',
      email: 'bob.wilson@example.com',
      address: '321 Maple Dr, Springfield',
      carePlan: 'Mobility assistance',
    ),
    Client(
      id: 'c5',
      name: 'Carol Brown',
      email: 'carol.brown@example.com',
      address: '654 Cedar Ln, Springfield',
      carePlan: 'Medication management',
    ),
  ];

  final List<Shift> _shifts = [
    Shift(
      id: 's1',
      clientId: 'c1',
      clientName: 'John Doe',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      status: 'pending',
    ),
    Shift(
      id: 's2',
      clientId: 'c2',
      clientName: 'Jane Smith',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
      status: 'pending',
    ),
    Shift(
      id: 's3',
      clientId: 'c3',
      clientName: 'Alice Johnson',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
      status: 'pending',
    ),
  ];

  List<Caregiver> get availableCaregivers =>
      _caregivers.where((cg) => cg.isAvailable).toList();

  List<Shift> get unassignedShifts =>
      _shifts.where((shift) => shift.caregiverId == null).toList();

  List<Shift> get allShifts => _shifts;

  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  bool _isShiftOverlap(DateTime startTime, DateTime endTime, String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      if ((caregiverId != null && shift.caregiverId == caregiverId) || shift.clientId == clientId) {
        if (!(endTime.isBefore(shift.startTime) || startTime.isAfter(shift.endTime))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can add shifts');
    }
    final client = _clients.firstWhere(
      (c) => c.id == clientId && c.name == clientName,
      orElse: () => throw Exception('Invalid client ID or name'),
    );
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (_isShiftOverlap(startTime, endTime, null, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
    final shift = Shift(
      id: 's${_shifts.length + 1}',
      clientId: clientId,
      clientName: clientName,
      startTime: startTime,
      endTime: endTime,
      status: 'pending',
    );
    _shifts.add(shift);
    notifyListeners();
  }

  Future<void> updateShift({
    required String shiftId,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can update shifts');
    }
    final shiftIndex = _shifts.indexWhere((s) => s.id == shiftId);
    if (shiftIndex == -1) {
      throw Exception('Shift not found');
    }
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (_isShiftOverlap(startTime, endTime, caregiverId ?? _shifts[shiftIndex].caregiverId, _shifts[shiftIndex].clientId)) {
      throw Exception('Shift overlaps with existing shift');
    }
    _shifts[shiftIndex].startTime = startTime;
    _shifts[shiftIndex].endTime = endTime;
    if (caregiverId != null && caregiverName != null) {
      _shifts[shiftIndex].caregiverId = caregiverId;
      _shifts[shiftIndex].caregiverName = caregiverName;
    }
    notifyListeners();
  }

  Future<void> updateShiftStatus({
    required String shiftId,
    required String status,
    Location? location,
  }) async {
    final shift = _shifts.firstWhere((s) => s.id == shiftId);
    if (status == 'in_session' && location == null) {
      throw Exception('Location is required for check-in');
    }
    shift.status = status;
    if (location != null) {
      shift.location = location;
    }
    notifyListeners();
  }

  void assignShift(String shiftId, String caregiverId, String caregiverName) {
    final shift = _shifts.firstWhere((shift) => shift.id == shiftId);
    if (_isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception('Caregiver is already assigned to another shift at this time');
    }
    shift.caregiverId = caregiverId;
    shift.caregiverName = caregiverName;
    shift.status = 'pending';
    notifyListeners();
  }
}
EOF

# 2. Create lib/providers/location_provider.dart
mkdir -p lib/providers
cat << 'EOF' > lib/providers/location_provider.dart
import 'dart:math';
import 'package:flutter/material.dart';

class Location {
  double latitude;
  double longitude;

  Location({required this.latitude, required this.longitude});
}

class LocationProvider with ChangeNotifier {
  final List<Location> _locations = [
    Location(latitude: 37.7749, longitude: -122.4194),
    Location(latitude: 37.7849, longitude: -122.4094),
    Location(latitude: 37.7949, longitude: -122.4294),
    Location(latitude: 37.7649, longitude: -122.3994),
    Location(latitude: 37.7549, longitude: -122.4394),
  ];

  Location getRandomLocation() {
    final random = Random();
    return _locations[random.nextInt(_locations.length)];
  }
}
EOF

# 3. Update lib/screens/admin_calendar_screen.dart
cat << 'EOF' > lib/screens/admin_calendar_screen.dart
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
EOF

# 4. Create lib/screens/shift_list_screen.dart
mkdir -p lib/screens
cat << 'EOF' > lib/screens/shift_list_screen.dart
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'admin_calendar_screen.dart';

class ShiftListScreen extends StatefulWidget {
  final DateTime selectedDay;

  const ShiftListScreen({super.key, required this.selectedDay});

  @override
  State<ShiftListScreen> createState() => _ShiftListScreenState();
}

class _ShiftListScreenState extends State<ShiftListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Shift> _getFilteredShifts(ShiftAssignmentProvider provider) {
    final shifts = provider.allShifts.where((shift) {
      final shiftDay = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);
      return isSameDay(shiftDay, widget.selectedDay);
    }).toList();

    return shifts.where((shift) {
      final matchesSearch = _searchQuery.isEmpty ||
          shift.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (shift.caregiverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesFilter = _selectedFilter == 'All' || shift.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'pending', 'in_session', 'completed'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by ID, client, or caregiver...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> _showShiftDetailsDialog(Shift shift) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Shift Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shift ID: ${shift.id}'),
              Text('Client: ${shift.clientName} (ID: ${shift.clientId})'),
              Text('Start: ${DateFormat('h:mm a, MMM d').format(shift.startTime)}'),
              Text('End: ${DateFormat('h:mm a, MMM d').format(shift.endTime)}'),
              Text('Caregiver: ${shift.caregiverName ?? 'Unassigned'}'),
              Text('Status: ${shift.status}'),
              Text('Location: ${shift.location != null ? '(${shift.location!.latitude}, ${shift.location!.longitude})' : 'Not set'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (shift.status == 'pending')
            ModernButton(
              text: 'Edit Shift',
              icon: Icons.edit,
              onPressed: () {
                Navigator.pop(context);
                final adminScreen = AdminCalendarScreen();
                adminScreen._showEditShiftDialog(shift);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Shifts on ${DateFormat('MMMM d, yyyy').format(widget.selectedDay)}',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          final shifts = _getFilteredShifts(provider);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 24),
                shifts.isEmpty
                    ? const Center(child: Text('No shifts found'))
                    : ListView.builder(
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
                                'Caregiver: ${shift.caregiverName ?? 'Unassigned'}\n'
                                'Status: ${shift.status}',
                              ),
                              onTap: () => _showShiftDetailsDialog(shift),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
EOF

# 5. Update lib/screens/caregiver_calendar_screen.dart
cat << 'EOF' > lib/screens/caregiver_calendar_screen.dart
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
EOF

# 6. Update lib/screens/visit_check_in_screen.dart
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
EOF

# 7. Update lib/screens/visit_check_out_screen.dart
cat << 'EOF' > lib/screens/visit_check_out_screen.dart
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
EOF

# 8. Update lib/screens/shift_assignment_screen.dart
sed -i'' -E \
  -e 's/DateFormat\('MMM d, h:mm a'\)\.format\(shift\.dateTime\)/DateFormat\('MMM d, h:mm a'\)\.format\(shift\.startTime\) + " - " + DateFormat\('h:mm a'\)\.format\(shift\.endTime\)/g' \
  -e 's/Text\("Unassigned"/Text\(shift\.status/g' \
  -e 's/color: Colors\.red\[600\]/color: shift\.status == "pending" ? Colors.red[600] : (shift.status == "in_session" ? Colors.blue[600] : Colors.green[600])/g' \
  lib/screens/shift_assignment_screen.dart

# 9. Update lib/main.dart
sed -i'' -E \
  -e '1i\
import 'package:homecare0x1/providers/location_provider.dart';\
import 'package:homecare0x1/screens/shift_list_screen.dart';' \
  -e '/ChangeNotifierProvider\(create: \(_\) => TaskProvider\(\)\),/a\
        ChangeNotifierProvider(create: (_) => LocationProvider()),' \
  -e '/case Routes\.syncStatus:/i\
            case Routes.shiftList:\
              return MaterialPageRoute(builder: (_) => ShiftListScreen(selectedDay: settings.arguments as DateTime));' \
  lib/main.dart

# 10. Update lib/constants.dart
sed -i'' -E \
  -e '/static const String syncStatus = .*/a\
  static const String shiftList = "/shift_list";' \
  lib/constants.dart

# 11. Stage and commit changes with Git
git add .
git commit -m "Implement timekeeping feature with shift scheduling and status updates"

# Check dependencies
check_dependencies

echo "Script completed. Updated files:"
echo "- lib/providers/shift_assignment_provider.dart"
echo "- lib/providers/location_provider.dart (created)"
echo "- lib/screens/admin_calendar_screen.dart"
echo "- lib/screens/shift_list_screen.dart (created)"
echo "- lib/screens/caregiver_calendar_screen.dart"
echo "- lib/screens/visit_check_in_screen.dart"
echo "- lib/screens/visit_check_out_screen.dart"
echo "- lib/screens/shift_assignment_screen.dart"
echo "- lib/main.dart"
echo "- lib/constants.dart"
echo "Changes staged and committed with Git."
echo "Run 'flutter pub get' if dependencies were added."
echo "Verify changes with 'git status' and test with 'flutter run'."
echo "Revert changes if needed with 'git reset --hard'."