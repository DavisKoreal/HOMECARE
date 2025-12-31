import os

def implement_logout_and_details():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    print("\n--- Updating lib/screens/caregiver_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "caregiver_dashboard.dart")
    
    dashboard_code = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/location.dart'; 
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/screens/care_notes_screen.dart';
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
  final LocationProvider _locationProvider = LocationProvider();
  
  // State
  CaregiverProfile? _profile;
  List<Shift> _myShifts = [];
  bool _isLoading = true;
  int _selectedIndex = 0; 
  bool _isClockedIn = false;
  String? _activeShiftId; 

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
        final profile = await _caregiverService.getCaregiverProfile(user.id);
        final allShifts = await _shiftService.getAllShifts();
        
        final myShifts = allShifts.where((s) => s.caregiverId == user.id).toList();
        myShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

        final activeShift = myShifts.firstWhere(
          (s) => s.status == 'in_session', 
          orElse: () => Shift(id: 'none', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none')
        );

        if (mounted) {
          setState(() {
            _profile = profile;
            _myShifts = myShifts;
            _isClockedIn = activeShift.status == 'in_session';
            _activeShiftId = activeShift.status == 'in_session' ? activeShift.id : null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Auth Logic (Logout) ---
  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      // Navigate to login and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // --- Clock In/Out Logic ---
  Future<void> _handleClockIn() async {
    final now = DateTime.now();
    final shiftToStart = _myShifts.firstWhere(
      (s) => s.status == 'pending' && s.startTime.difference(now).inHours.abs() < 24, 
      orElse: () => Shift(id: 'none', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none')
    );

    if (shiftToStart.status == 'none') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No relevant shift found to clock into."), backgroundColor: AppTheme.warningOrange));
      return;
    }

    setState(() => _isLoading = true);

    try {
      Location? location;
      try {
         final locData = await _locationProvider.getLocation();
         if (locData != null && locData['Location'] != null) {
            location = Location(
              latitude: locData['Location']['Latitude'] ?? 0.0, 
              longitude: locData['Location']['Longitude'] ?? 0.0
            );
         }
      } catch (e) {
        print("Location error: $e");
        location = Location(latitude: 0.0, longitude: 0.0); 
      }

      await _shiftService.updateShiftStatus(
        shiftId: shiftToStart.id, 
        status: 'in_session', 
        location: location
      );

      setState(() {
        _isClockedIn = true;
        _activeShiftId = shiftToStart.id;
        _isLoading = false;
      });
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Clocked In Successfully"), backgroundColor: AppTheme.successGreen));

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Clock In Failed: $e"), backgroundColor: AppTheme.errorRed));
    }
  }

  void _handleClockOut() {
    if (_activeShiftId == null) return;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(children: [Icon(Icons.check_circle_outline, size: 48, color: AppTheme.primaryPurple), SizedBox(height: 12), Text("Clock Out & Report")]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shift Summary / Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(hintText: "Summary of activities...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppTheme.neutral100),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performClockOut(_activeShiftId!, notesController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text("Confirm Clock Out"),
          ),
        ],
      ),
    );
  }

  Future<void> _performClockOut(String shiftId, String notes) async {
    setState(() => _isLoading = true);
    try {
      await _shiftService.updateShiftStatus(shiftId: shiftId, status: 'completed');
      setState(() {
        _isClockedIn = false;
        _activeShiftId = null;
        _isLoading = false;
      });
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift Completed"), backgroundColor: AppTheme.successGreen));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.errorRed));
    }
  }

  // --- Details Dialog ---
  void _showShiftDetails(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shift Details", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 32),
              _buildDetailItem(Icons.person, "Client", shift.clientName),
              const SizedBox(height: 16),
              _buildDetailItem(Icons.access_time, "Time", "${DateFormat('MMM d, y').format(shift.startTime)} • ${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}"),
              const SizedBox(height: 16),
              _buildDetailItem(Icons.location_on, "Address", "123 Mockingbird Lane, Suite 100"), 
              const SizedBox(height: 16),
              _buildDetailItem(Icons.info_outline, "Status", shift.status.toUpperCase(), 
                color: AppTheme.getStatusColor(shift.status)
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.phone), 
                      label: const Text("Call"),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.map), 
                      label: const Text("Directions"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Layout ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: AppTheme.backgroundCanvas,
          appBar: isDesktop 
              ? null 
              : AppBar(
                  title: Text(_getTitleForIndex(_selectedIndex)),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    ..._buildAppBarActions(),
                    // Mobile Logout
                    IconButton(icon: const Icon(Icons.logout, color: AppTheme.errorRed), onPressed: _handleLogout),
                  ],
                ),
          
          body: Row(
            children: [
              if (isDesktop)
                Column(
                  children: [
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                        extended: constraints.maxWidth >= 1000,
                        backgroundColor: Colors.white,
                        selectedIconTheme: const IconThemeData(color: AppTheme.primaryPurple),
                        unselectedIconTheme: const IconThemeData(color: AppTheme.neutral600),
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: FloatingActionButton.extended(
                            onPressed: _isClockedIn ? _handleClockOut : _handleClockIn,
                            backgroundColor: _isClockedIn ? AppTheme.errorRed : AppTheme.successGreen,
                            icon: Icon(_isClockedIn ? Icons.stop : Icons.play_arrow),
                            label: Text(constraints.maxWidth >= 1000 ? (_isClockedIn ? "Clock Out" : "Clock In") : ""),
                            isExtended: constraints.maxWidth >= 1000,
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                          NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Schedule')),
                          NavigationRailDestination(icon: Icon(Icons.note_add_outlined), selectedIcon: Icon(Icons.note_add), label: Text('Care Notes')),
                          NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
                        ],
                      ),
                    ),
                    // Desktop Logout Button at bottom of rail
                    Container(
                      width: constraints.maxWidth >= 1000 ? 200 : 72,
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 24, top: 12),
                      child: constraints.maxWidth >= 1000 
                        ? TextButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                            label: const Text("Log Out", style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                          )
                        : IconButton(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                            tooltip: "Log Out",
                          ),
                    ),
                  ],
                ),
              
              if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

              Expanded(child: _buildBody()),
            ],
          ),

          floatingActionButton: (!isDesktop && _selectedIndex == 0)
              ? FloatingActionButton.extended(
                  onPressed: _isClockedIn ? _handleClockOut : _handleClockIn,
                  backgroundColor: _isClockedIn ? AppTheme.errorRed : AppTheme.successGreen,
                  icon: Icon(_isClockedIn ? Icons.stop : Icons.play_arrow),
                  label: Text(_isClockedIn ? "Clock Out" : "Clock In"),
                ) 
              : null,
          bottomNavigationBar: isDesktop 
              ? null 
              : BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  selectedItemColor: AppTheme.primaryPurple,
                  unselectedItemColor: AppTheme.neutral600,
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
                    BottomNavigationBarItem(icon: Icon(Icons.note_add_outlined), label: 'Care Notes'),
                    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
                  ],
                ),
        );
      }
    );
  }

  // --- Helper Methods ---
  
  List<Widget> _buildAppBarActions() {
    return [
      IconButton(icon: const Icon(Icons.notifications_none, color: AppTheme.textPrimary), onPressed: () {}),
      IconButton(icon: const Icon(Icons.person_outline, color: AppTheme.textPrimary), onPressed: () => Navigator.pushNamed(context, Routes.caregiverProfile)),
    ];
  }

  String _getTitleForIndex(int index) {
    switch(index) {
      case 0: return 'Dashboard';
      case 1: return 'My Schedule';
      case 2: return 'Care Notes';
      case 3: return 'Profile';
      default: return 'Dashboard';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildOverviewTab();
      case 1: return _buildScheduleTab();
      case 2: return const CareNotesScreen(); 
      case 3: return _buildProfileStub();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final nextShift = _myShifts.firstWhere(
      (s) => s.status == 'in_session' || s.endTime.isAfter(DateTime.now()), 
      orElse: () => Shift(id: 'none', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none')
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 32),
          
          Text(_isClockedIn ? "Current Shift" : "Up Next", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          nextShift.status != 'none' ? _buildNextShiftCard(nextShift) : _buildEmptyState("No upcoming shifts scheduled."),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Shifts", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: const Text("View Schedule"))
            ],
          ),
          const SizedBox(height: 8),
          ..._myShifts.where((s) => s.status == 'completed').take(3).map((s) => _buildShiftCard(s)).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return _myShifts.isEmpty 
      ? _buildEmptyState("No shifts assigned yet.")
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _myShifts.length,
          itemBuilder: (context, index) => _buildShiftCard(_myShifts[index]),
        );
  }

  Widget _buildProfileStub() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModernButton(text: "View Full Profile", icon: Icons.person, onPressed: () => Navigator.pushNamed(context, Routes.caregiverProfile)),
          const SizedBox(height: 16),
          // Mobile might see this stub if they navigate to index 3
          ModernButton(text: "Log Out", icon: Icons.logout, color: AppTheme.errorRed, onPressed: _handleLogout),
        ],
      )
    );
  }

  // --- Widgets ---

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryPurple.withOpacity(0.1), child: Text(_profile?.name.isNotEmpty == true ? _profile!.name[0] : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple))),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hello, ${_profile?.name ?? 'Caregiver'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const Text("Ready to make a difference today?", style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        ])
      ],
    );
  }

  Widget _buildStatsRow() {
    double hours = 0;
    for (var s in _myShifts) { if (s.status == 'completed') hours += s.endTime.difference(s.startTime).inMinutes / 60.0; }
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: constraints.maxWidth > 600 ? 200 : constraints.maxWidth / 2 - 20, child: _buildStatCard("Earnings", "\$${(hours * (_profile?.hourlyRate ?? 15.0)).toStringAsFixed(0)}", Icons.attach_money, AppTheme.successGreen)),
        SizedBox(width: constraints.maxWidth > 600 ? 200 : constraints.maxWidth / 2 - 20, child: _buildStatCard("Hours", hours.toStringAsFixed(1), Icons.timer, AppTheme.primaryBlue)),
        SizedBox(width: constraints.maxWidth > 600 ? 200 : constraints.maxWidth, child: _buildStatCard("Rating", "${_profile?.rating ?? 5.0}", Icons.star, AppTheme.warningOrange)),
      ]);
    });
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderGray)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildNextShiftCard(Shift shift) {
    bool isActive = shift.status == 'in_session';
    return InkWell(
      onTap: () => _showShiftDetails(shift),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isActive ? [AppTheme.successGreen, const Color(0xFF00E676)] : [AppTheme.primaryPurple, const Color(0xFF7E60E8)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: (isActive ? AppTheme.successGreen : AppTheme.primaryPurple).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isActive ? "CURRENTLY ACTIVE" : "NEXT SHIFT", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: Text(DateFormat('MMM d').format(shift.startTime), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
          ]),
          const SizedBox(height: 16),
          Text(shift.clientName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Row(children: [Icon(Icons.location_on, color: Colors.white70, size: 16), SizedBox(width: 4), Text("123 Main St (Mock Address)", style: TextStyle(color: Colors.white70))]),
          const SizedBox(height: 24),
          Row(children: [const Icon(Icons.access_time, color: Colors.white, size: 20), const SizedBox(width: 8), Text("${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isActive ? _handleClockOut : _handleClockIn, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: isActive ? AppTheme.successGreen : AppTheme.primaryPurple, elevation: 0), child: Text(isActive ? "Clock Out Now" : "Clock In"))),
        ]),
      ),
    );
  }

  Widget _buildShiftCard(Shift shift) {
    return InkWell(
      onTap: () => _showShiftDetails(shift),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderGray)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.medical_services_outlined, color: AppTheme.neutral600)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(shift.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text("${DateFormat('MMM d').format(shift.startTime)} • ${DateFormat('h:mm a').format(shift.startTime)}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.getStatusColor(shift.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(shift.status.toUpperCase(), style: TextStyle(color: AppTheme.getStatusColor(shift.status), fontWeight: FontWeight.bold, fontSize: 12))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(children: [const Icon(Icons.event_busy, size: 40, color: AppTheme.neutral600), const SizedBox(height: 8), Text(message, style: const TextStyle(color: AppTheme.textSecondary))])));
  }
}
"""
    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dashboard_code)
    print("Enhanced Caregiver Dashboard with Logout and Shift Details.")

if __name__ == "__main__":
    implement_logout_and_details()