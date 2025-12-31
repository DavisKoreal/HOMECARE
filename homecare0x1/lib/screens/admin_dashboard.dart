import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/dashboard_shell.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

    return DashboardShell(
      title: 'Overview',
      activeRoute: Routes.adminDashboard,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
        ),
      ],
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.errorRed)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Welcome Section (Clean Text, No Gradient)
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

                      // 2. Key Metrics (Flat Cards)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive Grid for Metrics
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
                              _buildMetricCard(
                                'Recipients', 
                                _activeClients.toString(), 
                                Icons.people_outline, 
                                AppTheme.successGreen
                              ),
                              _buildMetricCard(
                                'Care Staff', 
                                _activeCaregivers.toString(), 
                                Icons.medical_services_outlined, 
                                AppTheme.primaryPurple
                              ),
                              _buildMetricCard(
                                'Pending Shifts', 
                                _pendingTasks.toString(), 
                                Icons.assignment_late_outlined, 
                                AppTheme.accentOrange
                              ),
                            ],
                          );
                        }
                      ),

                      const SizedBox(height: 40),

                      // 3. Quick Actions Header
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Action Grid
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
                            childAspectRatio: 1.2, // Rectangular action cards
                            children: [
                              _buildActionCard(
                                'New Shift',
                                'Create assignment',
                                Icons.add_task,
                                () => Navigator.pushNamed(context, Routes.adminInitiateShift),
                              ),
                              _buildActionCard(
                                'Add Client',
                                'New recipient',
                                Icons.person_add_outlined,
                                () => Navigator.pushNamed(context, Routes.adminAddClient),
                              ),
                              _buildActionCard(
                                'Add Caregiver',
                                'New staff member',
                                Icons.person_add_alt,
                                () => Navigator.pushNamed(context, Routes.adminAddCaregiver),
                              ),
                              _buildActionCard(
                                'Approve Staff',
                                'Review applications',
                                Icons.verified_user_outlined,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminCaregiverApprovalPage(
                                      adminId: user?.id ?? '',
                                    ),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                'Calendar',
                                'View schedule',
                                Icons.calendar_today,
                                () => Navigator.pushNamed(context, Routes.adminCalendar),
                              ),
                              _buildActionCard(
                                'System Logs',
                                'View audit trail',
                                Icons.security,
                                () => Navigator.pushNamed(context, Routes.auditLog),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Sharp corners
        border: Border.all(color: AppTheme.borderGray), // Border instead of shadow
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
              // Optional: Add trend indicator here
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
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
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
