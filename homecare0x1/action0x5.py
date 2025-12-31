import os

def make_admin_spa():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update DashboardShell to support SPA Navigation
    # ---------------------------------------------------------
    print("\n--- Updating lib/widgets/dashboard_shell.dart ---")
    shell_path = os.path.join("lib", "widgets", "dashboard_shell.dart")
    
    # We are rewriting it to support the onNavigate callback properly
    shell_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';

class DashboardShell extends StatelessWidget {
  final Widget content;
  final String title;
  final List<Widget>? actions;
  final String activeRoute;
  final Function(String route)? onNavigate; // New callback for SPA mode

  const DashboardShell({
    super.key,
    required this.content,
    required this.title,
    required this.activeRoute,
    this.actions,
    this.onNavigate,
  });

  void _handleLogout(BuildContext context) async {
    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: const Color(0xFF2D3436),
              child: _buildSidebarContent(context),
            )
          : null,
      appBar: !isDesktop
          ? AppBar(
              title: Text(title, style: const TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 1,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: actions,
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 260,
              color: const Color(0xFF2D3436),
              child: _buildSidebarContent(context),
            ),
          Expanded(
            child: Column(
              children: [
                if (isDesktop)
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Row(children: actions ?? []),
                      ],
                    ),
                  ),
                Expanded(
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'homecare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              ...NavigationConfig.sidebarItems.map((item) {
                final isActive = activeRoute == item['route'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isActive ? AppTheme.primaryPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (activeRoute == item['route']) return;
                        
                        // SPA Logic: If callback exists, use it. Else push route.
                        if (onNavigate != null) {
                          onNavigate!(item['route']);
                        } else {
                          Navigator.pushReplacementNamed(context, item['route']);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              color: isActive ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: InkWell(
            onTap: () => _handleLogout(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
"""
    with open(shell_path, "w", encoding="utf-8") as f:
        f.write(shell_content)
    print("Updated DashboardShell.")

    # ---------------------------------------------------------
    # 2. Extract Overview Content to separate file
    # ---------------------------------------------------------
    print("\n--- Creating lib/screens/admin_overview_view.dart ---")
    overview_path = os.path.join("lib", "screens", "admin_overview_view.dart")
    
    overview_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';

class AdminOverviewView extends StatefulWidget {
  final Function(String) onNavigate;

  const AdminOverviewView({super.key, required this.onNavigate});

  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView> {
  int _activeClients = 0;
  int _activeCaregivers = 0;
  int _pendingTasks = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final shiftProvider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
      await Future.wait([
        shiftProvider.fetchClients(),
        shiftProvider.fetchCaregivers(),
        shiftProvider.fetchShifts(),
      ]);

      if (mounted) {
        setState(() {
          _activeClients = shiftProvider.clients.length;
          _activeCaregivers = shiftProvider.availableCaregivers.length;
          _pendingTasks = shiftProvider.shifts.where((shift) => shift.status == 'pending').length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.errorRed)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${user?.name ?? "Admin"}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is what is happening with your care team today.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = width > 900 ? 3 : (width > 600 ? 2 : 1);
              double aspectRatio = width > 900 ? 1.5 : 2.0;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
                children: [
                  _buildMetricCard('Recipients', _activeClients.toString(), Icons.people_outline, AppTheme.successGreen),
                  _buildMetricCard('Care Staff', _activeCaregivers.toString(), Icons.medical_services_outlined, AppTheme.primaryPurple),
                  _buildMetricCard('Pending Shifts', _pendingTasks.toString(), Icons.assignment_late_outlined, AppTheme.accentOrange),
                ],
              );
            }
          ),
          const SizedBox(height: 40),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = width > 1100 ? 4 : (width > 700 ? 3 : 2);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    'New Shift', 'Create assignment', Icons.add_task, 
                    () => widget.onNavigate(Routes.adminInitiateShift)
                  ),
                  _buildActionCard(
                    'Add Client', 'New recipient', Icons.person_add_outlined, 
                    () => widget.onNavigate(Routes.adminAddClient)
                  ),
                  _buildActionCard(
                    'Add Caregiver', 'New staff member', Icons.person_add_alt, 
                    () => widget.onNavigate(Routes.adminAddCaregiver)
                  ),
                  _buildActionCard(
                    'Approve Staff', 'Review applications', Icons.verified_user_outlined, 
                    () => widget.onNavigate(Routes.adminCaregiverApproval)
                  ),
                  _buildActionCard(
                    'Calendar', 'View schedule', Icons.calendar_today, 
                    () => widget.onNavigate(Routes.adminCalendar)
                  ),
                  _buildActionCard(
                    'System Logs', 'View audit trail', Icons.security, 
                    () => widget.onNavigate(Routes.auditLog)
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 28),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
"""
    with open(overview_path, "w", encoding="utf-8") as f:
        f.write(overview_content)
    print("Created AdminOverviewView.")

    # ---------------------------------------------------------
    # 3. Refactor Admin Dashboard to be the SPA Controller
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "admin_dashboard.dart")
    
    # This is the 'Main Controller' file now
    dashboard_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/widgets/dashboard_shell.dart';
import 'package:homecare0x1/theme/app_theme.dart';

// Import All Screens that need to be shown in the content area
import 'package:homecare0x1/screens/admin_overview_view.dart';
import 'package:homecare0x1/screens/admin_calendar_screen.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/admin_notes_management_screen.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/admin_initiate_shift.dart';
import 'package:homecare0x1/screens/admin_add_client.dart';
import 'package:homecare0x1/screens/admin_add_caregiver.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';
import 'package:homecare0x1/providers/user_provider.dart'; // Needed for adminId passed to approval
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // State: The currently active route in the content area
  String _currentRoute = Routes.adminDashboard;

  // Method to switch views (passed down to children)
  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: _getTitleForRoute(_currentRoute),
      activeRoute: _currentRoute,
      onNavigate: _navigateTo, // Pass the callback to the Shell
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
        ),
      ],
      // The body of the Shell is now dynamic based on _currentRoute
      content: _getViewForRoute(_currentRoute),
    );
  }

  // Helper to determine the Page Title
  String _getTitleForRoute(String route) {
    switch (route) {
      case Routes.adminDashboard: return 'Overview';
      case Routes.adminCalendar: return 'Calendar';
      case Routes.shiftAssignment: return 'Shift Assignments';
      case Routes.clientList: return 'Recipients';
      case Routes.adminNotesManagement: return 'Care Notes';
      case Routes.auditLog: return 'System Logs';
      case Routes.adminInitiateShift: return 'New Shift';
      case Routes.adminAddClient: return 'Add Recipient';
      case Routes.adminAddCaregiver: return 'Add Staff';
      case Routes.adminCaregiverApproval: return 'Staff Approval';
      default: return 'HomeCare';
    }
  }

  // Helper to return the correct Widget
  Widget _getViewForRoute(String route) {
    // Note: We wrap secondary screens in a ClipRect or similar if needed, 
    // but standard widgets work fine in the Expanded content area.
    switch (route) {
      case Routes.adminDashboard:
        return AdminOverviewView(onNavigate: _navigateTo);
        
      case Routes.adminCalendar:
        return const AdminCalendarScreen();
        
      case Routes.shiftAssignment:
        return const ShiftAssignmentScreen();
        
      case Routes.clientList:
        return const ClientListScreen();
        
      case Routes.adminNotesManagement:
        return const AdminNotesManagementScreen();
        
      case Routes.auditLog:
        return const AuditLogScreen();

      case Routes.adminInitiateShift:
        return const AdminInitiateShift();

      case Routes.adminAddClient:
        return const AdminAddClientScreen();

      case Routes.adminAddCaregiver:
        return const AdminAddCaregiverPage();

      case Routes.adminCaregiverApproval:
        final adminId = Provider.of<UserProvider>(context, listen: false).user?.id ?? '';
        return AdminCaregiverApprovalPage(adminId: adminId);

      default:
        return Center(child: Text("Page not found for $route"));
    }
  }
}
"""
    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dashboard_content)
    print("Refactored AdminDashboardScreen to SPA Controller.")

if __name__ == "__main__":
    make_admin_spa()