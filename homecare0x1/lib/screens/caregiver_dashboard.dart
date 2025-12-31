import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  // Services
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;
  final AuthService _authService = AuthService();
  
  // State
  CaregiverProfile? _profile;
  List<Shift> _myShifts = [];
  List<Shift> _availableShifts = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // For Bottom Nav simulation

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // 1. Fetch Profile
        final profile = await _caregiverService.getCaregiverProfile(user.id);
        
        // 2. Fetch Shifts
        final allShifts = await _shiftService.getAllShifts();
        
        // Filter Logic
        final myShifts = allShifts.where((s) => s.caregiverId == user.id).toList();
        final openShifts = allShifts.where((s) => s.caregiverId == null && s.status == 'pending').toList();

        // Sort by date
        myShifts.sort((a, b) => a.startTime.compareTo(b.startTime));
        openShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

        if (mounted) {
          setState(() {
            _profile = profile;
            _myShifts = myShifts;
            _availableShifts = openShifts;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : _selectedIndex == 1 ? 'My Schedule' : 'Marketplace'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pushNamed(context, Routes.caregiverProfile),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.neutral600,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildOverviewTab();
      case 1: return _buildScheduleTab();
      case 2: return _buildMarketplaceTab();
      case 3: 
        // Redirect to profile logic or show stub
        return Center(
          child: ModernButton(
            text: "Go to Full Profile", 
            icon: Icons.person,
            onPressed: () => Navigator.pushNamed(context, Routes.caregiverProfile)
          )
        );
      default: return _buildOverviewTab();
    }
  }

  // --- TAB 1: OVERVIEW ---
  Widget _buildOverviewTab() {
    // Find next shift
    final nextShift = _myShifts.firstWhere(
      (s) => s.endTime.isAfter(DateTime.now()), 
      orElse: () => Shift(id: 'none', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none')
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 32),
          
          Text("Up Next", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          nextShift.status != 'none' 
            ? _buildNextShiftCard(nextShift)
            : _buildEmptyState("No upcoming shifts scheduled."),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("New Opportunities", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text("View All"),
              )
            ],
          ),
          const SizedBox(height: 8),
          ..._availableShifts.take(3).map((s) => _buildShiftCard(s, isActionable: true)).toList(),
        ],
      ),
    );
  }

  // --- TAB 2: SCHEDULE ---
  Widget _buildScheduleTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _myShifts.length,
      itemBuilder: (context, index) => _buildShiftCard(_myShifts[index]),
    );
  }

  // --- TAB 3: MARKETPLACE ---
  Widget _buildMarketplaceTab() {
    return _availableShifts.isEmpty 
      ? const Center(child: Text("No open shifts available right now."))
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _availableShifts.length,
          itemBuilder: (context, index) => _buildShiftCard(_availableShifts[index], isActionable: true),
        );
  }

  // --- WIDGETS ---

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
          child: Text(
            _profile?.name.isNotEmpty == true ? _profile!.name[0] : 'U',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${_profile?.name ?? 'Caregiver'}", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)
            ),
            const Text("Ready to make a difference today?", style: TextStyle(color: AppTheme.textSecondary)),
          ],
        )
      ],
    );
  }

  Widget _buildStatsRow() {
    // Calculate total hours (Mock calculation for demo)
    double hours = 0;
    for (var s in _myShifts) {
      if (s.status == 'completed') {
        hours += s.endTime.difference(s.startTime).inMinutes / 60.0;
      }
    }

    return Row(
      children: [
        Expanded(child: _buildStatCard("Earnings", "\$${(hours * (_profile?.hourlyRate ?? 15.0)).toStringAsFixed(0)}", Icons.attach_money, AppTheme.successGreen)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Hours", hours.toStringAsFixed(1), Icons.timer, AppTheme.primaryBlue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Rating", "${_profile?.rating ?? 5.0}", Icons.star, AppTheme.warningOrange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNextShiftCard(Shift shift) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFF7E60E8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NEXT SHIFT", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: Text(DateFormat('MMM d').format(shift.startTime), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(shift.clientName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text("123 Main St (Mock Address)", style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Shift Details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryPurple,
                elevation: 0,
              ),
              child: const Text("View Details & Clock In"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShiftCard(Shift shift, {bool isActionable = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medical_services_outlined, color: AppTheme.neutral600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  "${DateFormat('MMM d').format(shift.startTime)} • ${DateFormat('h:mm a').format(shift.startTime)}",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isActionable)
            ElevatedButton(
              onPressed: () {
                // Request Shift Logic
                _shiftService.assignShift(shift.id, _profile!.id, _profile!.name); // Auto-assign for demo
                _loadDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift Requested!"), backgroundColor: AppTheme.successGreen));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text("Accept"),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.getStatusColor(shift.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                shift.status.toUpperCase(),
                style: TextStyle(color: AppTheme.getStatusColor(shift.status), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.event_busy, size: 40, color: AppTheme.neutral600),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
