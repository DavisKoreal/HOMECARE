#!/bin/bash

# Create or overwrite files with the updated content

# Update lib/providers/shift_assignment_provider.dart
cat > lib/providers/shift_assignment_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

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

  List<Shift> get requestShifts =>
      _shifts.where((shift) => shift.status == 'request').toList();

  List<Shift> get allShifts => _shifts;

  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  bool _isShiftOverlap(DateTime startTime, DateTime endTime,
      String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      if ((caregiverId != null && shift.caregiverId == caregiverId) ||
          shift.clientId == clientId) {
        if (!(endTime.isBefore(shift.startTime) ||
            startTime.isAfter(shift.endTime))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> requestShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
    final client = _clients.firstWhere(
      (c) => c.id == clientId && c.name == clientName,
      orElse: () => throw Exception('Invalid client ID or name'),
    );
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Start time must be in the future');
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
      status: 'request',
    );
    _shifts.add(shift);
    notifyListeners();
  }

  Future<void> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
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
    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Start time must be in the future');
    }
    if (_isShiftOverlap(startTime, endTime, caregiverId, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
    final shift = Shift(
      id: 's${_shifts.length + 1}',
      clientId: clientId,
      clientName: clientName,
      startTime: startTime,
      endTime: endTime,
      caregiverId: caregiverId,
      caregiverName: caregiverName,
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
    if (_isShiftOverlap(
        startTime, endTime, caregiverId ?? _shifts[shiftIndex].caregiverId,
        _shifts[shiftIndex].clientId)) {
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
    if (_isShiftOverlap(
        shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception(
          'Caregiver is already assigned to another shift at this time');
    }
    shift.caregiverId = caregiverId;
    shift.caregiverName = caregiverName;
    if (shift.status == 'request') {
      shift.status = 'pending';
    }
    notifyListeners();
  }
}
EOF

# Update lib/screens/family_portal_screen.dart
cat > lib/screens/family_portal_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FamilyPortalScreen extends StatefulWidget {
  const FamilyPortalScreen({super.key});

  @override
  State<FamilyPortalScreen> createState() => _FamilyPortalScreenState();
}

class _FamilyPortalScreenState extends State<FamilyPortalScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _statsAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _statsAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _statsAnimationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _showRequestShiftDialog(BuildContext context) async {
    DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime? endTime = startTime.add(const Duration(hours: 2));
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request Caregiving Session'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernButton(
                  text: 'Select Start Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime!),
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
                ModernButton(
                  text: 'Select End Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime!),
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
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (startTime == null || endTime == null) {
                setState(() {
                  errorMessage = 'Please select both start and end times';
                });
                return;
              }
              if (startTime!.isBefore(DateTime.now())) {
                setState(() {
                  errorMessage = 'Start time must be in the future';
                });
                return;
              }
              if (startTime!.isAfter(endTime!)) {
                setState(() {
                  errorMessage = 'Start time must be before end time';
                });
                return;
              }
              try {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final shiftProvider =
                    Provider.of<ShiftAssignmentProvider>(context, listen: false);
                await shiftProvider.requestShift(
                  clientId: userProvider.user!.id,
                  clientName: userProvider.user!.name,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request submitted')),
                );
              } catch (e) {
                setState(() {
                  errorMessage = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStat({
    required String title,
    required String value,
    required double percent,
    required Color color,
    required IconData icon,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(
                            milliseconds:
                                1000 + (animation.value * 500).round()),
                        tween:
                            Tween(begin: 0.0, end: percent * animation.value),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: color.withOpacity(0.1),
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation(color),
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<int>(
                  duration: Duration(
                      milliseconds: 1000 + (animation.value * 500).round()),
                  tween: IntTween(begin: 0, end: int.parse(value)),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    if (badge != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: color,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Logout Confirmation'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout and return to the login screen?',
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Family Member';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLogout = await _confirmLogout(context);
        if (shouldLogout && context.mounted) {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Color(0xFF9B59B6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Family Portal',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF7F8C8D),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, Routes.messages),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF7F8C8D),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.userProfile),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9B59B6),
                            Color(0xFFAB7FB8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B59B6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome, $userName!",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Stay connected with your loved one's care",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.family_restroom,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.update,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Last update: 2 hours ago',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Today's Overview
                    const Text(
                      'Care Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernStat(
                            title: 'Recent Visits',
                            value: '4',
                            percent: 0.8,
                            color: const Color(0xFF3498DB),
                            icon: Icons.event_available,
                            animation: _statsAnimations[0],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernStat(
                            title: 'Care Notes',
                            value: '12',
                            percent: 0.75,
                            color: const Color(0xFF00A86B),
                            icon: Icons.note_outlined,
                            animation: _statsAnimations[1],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernStat(
                            title: 'Messages',
                            value: '5',
                            percent: 0.5,
                            color: const Color(0xFFE67E22),
                            icon: Icons.message_outlined,
                            animation: _statsAnimations[2],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions Section
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildModernActionCard(
                          title: 'Request Caregiving Session',
                          subtitle: 'Request a new caregiving session for your loved one',
                          icon: Icons.schedule,
                          color: AppTheme.secondaryTeal,
                          onTap: () => _showRequestShiftDialog(context),
                        ),
                        _buildModernActionCard(
                          title: 'Caregiver Profile',
                          subtitle:
                              'View your caregiver\'s details and contact information',
                          icon: Icons.person,
                          color: const Color(0xFF3498DB),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.clientProfile),
                        ),
                        _buildModernActionCard(
                          title: 'Messages',
                          subtitle:
                              'Communicate with your caregiver and give instructions',
                          icon: Icons.message,
                          color: const Color(0xFF9B59B6),
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.messages),
                          badge: '5',
                        ),
                        _buildModernActionCard(
                          title: 'Care Notes',
                          subtitle: 'View detailed notes from your caregiver',
                          icon: Icons.note,
                          color: const Color(0xFF00A86B),
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.careNotes),
                          badge: '3',
                        ),
                        _buildModernActionCard(
                          title: 'Visit History',
                          subtitle: 'Track all recent visits and activities',
                          icon: Icons.history,
                          color: const Color(0xFFE67E22),
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.auditLog),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Payment & Support Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernActionCard(
                            title: 'Payment Status',
                            subtitle: 'View billing and payment information',
                            icon: Icons.payment,
                            color: const Color(0xFF16A085),
                            onTap: () => Navigator.pushNamed(
                                context, Routes.paymentStatus),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernActionCard(
                            title: 'Support Center',
                            subtitle: 'Get help and contact our support team',
                            icon: Icons.support_agent,
                            color: const Color(0xFFF39C12),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening support center...'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Section
                    const Text(
                      'Recent Updates',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            title: 'New care note added',
                            subtitle:
                                'Daily wellness check completed successfully',
                            time: '2 hours ago',
                            icon: Icons.note_add,
                            color: const Color(0xFF00A86B),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Message received',
                            subtitle: 'Your caregiver sent you an update',
                            time: '4 hours ago',
                            icon: Icons.message,
                            color: const Color(0xFF9B59B6),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Visit completed',
                            subtitle: 'Morning care visit - 3 hours',
                            time: 'Yesterday',
                            icon: Icons.check_circle,
                            color: const Color(0xFF3498DB),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# Update lib/screens/shift_assignment_screen.dart
cat > lib/screens/shift_assignment_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShiftAssignmentScreen extends StatefulWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  State<ShiftAssignmentScreen> createState() => _ShiftAssignmentScreenState();
}

class _ShiftAssignmentScreenState extends State<ShiftAssignmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isAssigning = false;
  String? _selectedShiftId;
  String? _selectedCaregiverId;
  bool _showCaregiverDetails = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateShiftDialog() async {
    final clientController = TextEditingController();
    String? selectedClientId;
    String? selectedCaregiverId;
    DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime? endTime = startTime.add(const Duration(hours: 2));
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Shift'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedClientId,
                      items: provider._clients
                          .map((client) => DropdownMenuItem<String>(
                                value: client.id,
                                child: Text(client.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClientId = value;
                          clientController.text = value != null
                              ? provider._clients
                                  .firstWhere((c) => c.id == value)
                                  .name
                              : '';
                          errorMessage = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Caregiver (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCaregiverId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...provider.availableCaregivers
                            .map((caregiver) => DropdownMenuItem<String>(
                                  value: caregiver.id,
                                  child: Text(caregiver.name),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCaregiverId = value;
                          errorMessage = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ModernButton(
                  text: 'Select Start Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime!),
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
                ModernButton(
                  text: 'Select End Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime!),
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
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedClientId == null) {
                setState(() {
                  errorMessage = 'Please select a client';
                });
                return;
              }
              if (startTime == null || endTime == null) {
                setState(() {
                  errorMessage = 'Please select both start and end times';
                });
                return;
              }
              if (startTime!.isBefore(DateTime.now())) {
                setState(() {
                  errorMessage = 'Start time must be in the future';
                });
                return;
              }
              if (startTime!.isAfter(endTime!)) {
                setState(() {
                  errorMessage = 'Start time must be before end time';
                });
                return;
              }
              try {
                final shiftProvider =
                    Provider.of<ShiftAssignmentProvider>(context, listen: false);
                final clientName = shiftProvider._clients
                    .firstWhere((c) => c.id == selectedClientId)
                    .name;
                final caregiverName = selectedCaregiverId != null
                    ? shiftProvider.availableCaregivers
                        .firstWhere((c) => c.id == selectedCaregiverId)
                        .name
                    : null;
                await shiftProvider.addShift(
                  clientId: selectedClientId!,
                  clientName: clientName,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                  caregiverId: selectedCaregiverId,
                  caregiverName: caregiverName,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift created successfully')),
                );
              } catch (e) {
                setState(() {
                  errorMessage = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create Shift'),
          ),
        ],
      ),
    );
  }

  void _assignCaregiver(BuildContext context, Shift shift) {
    final provider =
        Provider.of<ShiftAssignmentProvider>(context, listen: false);
    final availableCaregivers = provider.availableCaregivers;

    setState(() {
      _selectedShiftId = shift.id;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assign Caregiver',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Client: ${shift.clientName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            DateFormat('MMM d, h:mm a').format(shift.startTime),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedShiftId = null;
                          _selectedCaregiverId = null;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Caregivers list
              Expanded(
                child: availableCaregivers.isEmpty
                    ? _buildEmptyState(
                        'No available caregivers', Icons.person_off)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableCaregivers.length,
                        itemBuilder: (context, index) {
                          final caregiver = availableCaregivers[index];
                          final isSelected =
                              _selectedCaregiverId == caregiver.id;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? AppTheme.primaryBlue.withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Text(
                                caregiver.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected ? AppTheme.primaryBlue : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[600],
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Available'),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Experience: 3+ years',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryBlue,
                                    )
                                  : const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                              onTap: () {
                                setModalState(() {
                                  _selectedCaregiverId =
                                      isSelected ? null : caregiver.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),

              // Action buttons
              if (_selectedCaregiverId != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCaregiverId = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isAssigning
                              ? null
                              : () async {
                                  setState(() {
                                    _isAssigning = true;
                                  });

                                  final selectedCaregiver =
                                      availableCaregivers.firstWhere(
                                          (c) => c.id == _selectedCaregiverId);

                                  // Simulate assignment delay
                                  await Future.delayed(
                                      const Duration(milliseconds: 800));

                                  provider.assignShift(
                                    shift.id,
                                    selectedCaregiver.id,
                                    selectedCaregiver.name,
                                  );

                                  setState(() {
                                    _isAssigning = false;
                                    _selectedShiftId = null;
                                    _selectedCaregiverId = null;
                                  });

                                  Navigator.pop(context);

                                  // Show success animation
                                  _showSuccessSnackBar(
                                    'Successfully assigned ${selectedCaregiver.name} to ${shift.clientName}\'s shift',
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAssigning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Assign Caregiver',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
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
          hintText: 'Search caregivers or clients...',
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Urgent', 'Today', 'This Week', 'Requests'];

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

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Available\nCaregivers',
                  provider.availableCaregivers.length.toString(),
                  Icons.people,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pending\nAssignments',
                  provider.unassignedShifts.length.toString(),
                  Icons.assignment_late,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Shift Assignment',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateShiftDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<ShiftAssignmentProvider>(
            builder: (context, provider, child) {
              final unassignedShifts = provider.unassignedShifts;
              final requestShifts = provider.requestShifts;

              // Combine and filter shifts based on search query and filter
              final allShifts = [...unassignedShifts, ...requestShifts];
              final filteredShifts = allShifts.where((shift) {
                final matchesSearch = _searchQuery.isEmpty ||
                    shift.clientName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                final matchesFilter = _selectedFilter == 'All' ||
                    (_selectedFilter == 'Requests' &&
                        shift.status == 'request') ||
                    (_selectedFilter != 'Requests' &&
                        shift.status != 'request');
                return matchesSearch && matchesFilter;
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats card
                    _buildStatsCard(),

                    // Search bar
                    _buildSearchBar(),

                    // Filter chips
                    _buildFilterChips(),

                    const SizedBox(height: 24),

                    // Available Caregivers Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Caregivers',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Text(
                              '${provider.availableCaregivers.length}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    provider.availableCaregivers.isEmpty
                        ? Container(
                            height: 120,
                            child: _buildEmptyState(
                                'No caregivers available', Icons.person_off),
                          )
                        : Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.availableCaregivers.length,
                              itemBuilder: (context, index) {
                                final caregiver =
                                    provider.availableCaregivers[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundColor: AppTheme.primaryBlue
                                              .withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            color: AppTheme.primaryBlue,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          caregiver.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Available',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                    const SizedBox(height: 32),

                    // Unassigned Shifts Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_late,
                            color: Colors.orange[600],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pending Assignments',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Text(
                              '${filteredShifts.length}',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    filteredShifts.isEmpty
                        ? Container(
                            height: 200,
                            child: _buildEmptyState(
                              _searchQuery.isNotEmpty
                                  ? 'No shifts match your search'
                                  : 'No unassigned shifts',
                              Icons.assignment_turned_in,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredShifts.length,
                            itemBuilder: (context, index) {
                              final shift = filteredShifts[index];
                              final isSelected = _selectedShiftId == shift.id;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : Colors.grey[200]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.event,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                  title: Text(
                                    shift.clientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM d, h:mm a')
                                                .format(shift.startTime),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: shift.status == 'request'
                                              ? Colors.red[50]
                                              : Colors.red[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          shift.status == 'request'
                                              ? 'Request'
                                              : 'Unassigned',
                                          style: TextStyle(
                                            color: shift.status == 'request'
                                                ? Colors.red[600]
                                                : Colors.red[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppTheme.primaryBlue,
                                    size: 18,
                                  ),
                                  onTap: () => _assignCaregiver(context, shift),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
EOF


# Update lib/screens/shift_list_screen.dart
cat > lib/screens/shift_list_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Shift> _getFilteredShifts(ShiftAssignmentProvider provider) {
    final shifts = provider.allShifts.where((shift) {
      final shiftDay = DateTime(
          shift.startTime.year, shift.startTime.month, shift.startTime.day);
      return isSameDay(shiftDay, widget.selectedDay);
    }).toList();

    return shifts.where((shift) {
      final matchesSearch = _searchQuery.isEmpty ||
          shift.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (shift.caregiverName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesFilter =
          _selectedFilter == 'All' || shift.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'pending', 'in_session', 'completed', 'request'];

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
            padding: const EdgeInsets.only
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
          hintText: 'Search shifts, clients, or caregivers...',
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

  Future<void> _showEditShiftDialog(Shift shift) async {
    DateTime? startTime = shift.startTime;
    DateTime? endTime = shift.endTime;
    String? selectedCaregiverId = shift.caregiverId;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Shift'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Caregiver (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCaregiverId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...provider.availableCaregivers
                            .map((caregiver) => DropdownMenuItem<String>(
                                  value: caregiver.id,
                                  child: Text(caregiver.name),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCaregiverId = value;
                          errorMessage = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ModernButton(
                  text: 'Select Start Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime!),
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
                ModernButton(
                  text: 'Select End Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime!),
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
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (startTime == null || endTime == null) {
                setState(() {
                  errorMessage = 'Please select both start and end times';
                });
                return;
              }
              if (startTime!.isBefore(DateTime.now())) {
                setState(() {
                  errorMessage = 'Start time must be in the future';
                });
                return;
              }
              if (startTime!.isAfter(endTime!)) {
                setState(() {
                  errorMessage = 'Start time must be before end time';
                });
                return;
              }
              try {
                final shiftProvider =
                    Provider.of<ShiftAssignmentProvider>(context, listen: false);
                final caregiverName = selectedCaregiverId != null
                    ? shiftProvider.availableCaregivers
                        .firstWhere((c) => c.id == selectedCaregiverId)
                        .name
                    : null;
                await shiftProvider.updateShift(
                  shiftId: shift.id,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                  caregiverId: selectedCaregiverId,
                  caregiverName: caregiverName,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift updated successfully')),
                );
              } catch (e) {
                setState(() {
                  errorMessage = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update Shift'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Shifts for ${DateFormat('MMM d, yyyy').format(widget.selectedDay)}',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminCalendarScreen(
            initialDate: widget.selectedDay,
          ),
        ),
      ),
      body: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          final filteredShifts = _getFilteredShifts(provider);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                _buildSearchBar(),

                // Filter chips
                _buildFilterChips(),

                const SizedBox(height: 24),

                // Shifts List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Shifts (${filteredShifts.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                filteredShifts.isEmpty
                    ? Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No shifts for this day'
                                    : 'No shifts match your search',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredShifts.length,
                        itemBuilder: (context, index) {
                          final shift = filteredShifts[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.getStatusColor(shift.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event,
                                  color: AppTheme.getStatusColor(shift.status),
                                ),
                              ),
                              title: Text(
                                shift.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (shift.caregiverName != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          shift.caregiverName!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getStatusColor(shift.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      shift.status,
                                      style: TextStyle(
                                        color:
                                            AppTheme.getStatusColor(shift.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: () => _showEditShiftDialog(shift),
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
EOF

# Update lib/theme/app_theme.dart
cat > lib/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color secondaryTeal = Color(0xFF1ABC9C);
  static const Color errorRed = Color(0xFFE74C3C);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        secondary: secondaryTeal,
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF2C3E50),
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Color(0xFF7F8C8D),
        ),
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[600]!;
      case 'in_session':
        return Colors.blue[600]!;
      case 'completed':
        return Colors.green[600]!;
      case 'request':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
EOF

# Update lib/widgets/common/modern_button.dart
cat > lib/widgets/common/modern_button.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;

  const ModernButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(
              icon,
              size: 20,
            ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# Update lib/widgets/common/modern_screen_layout.dart
cat > lib/widgets/common/modern_screen_layout.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernScreenLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? floatingActionButton;

  const ModernScreenLayout({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.primaryBlue,
                ),
                onPressed: onBackPressed ??
                    () => Navigator.pop(context),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
EOF

# Update lib/constants.dart
cat > lib/constants.dart << 'EOF'
class Routes {
  static const String login = '/login';
  static const String adminDashboard = '/admin_dashboard';
  static const String clientProfile = '/client_profile';
  static const String messages = '/messages';
  static const String careNotes = '/care_notes';
  static const String auditLog = '/audit_log';
  static const String paymentStatus = '/payment_status';
  static const String userProfile = '/user_profile';
}
EOF


echo "Project files have been updated successfully!"