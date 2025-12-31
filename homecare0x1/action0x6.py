import os

def refactor_quick_actions():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    print("\n--- Refactoring Quick Actions in lib/screens/admin_overview_view.dart ---")
    file_path = os.path.join("lib", "screens", "admin_overview_view.dart")
    
    new_content = """import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
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
          
          // Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = width > 900 ? 3 : (width > 600 ? 2 : 1);
              // Aspect ratio adjusted for flatter metric cards
              double aspectRatio = width > 900 ? 2.5 : 2.0; 
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspectRatio,
                children: [
                  _buildMetricCard('Recipients', _activeClients.toString(), Icons.people_outline, AppTheme.successGreen),
                  _buildMetricCard('Care Staff', _activeCaregivers.toString(), Icons.medical_services_outlined, AppTheme.primaryPurple),
                  _buildMetricCard('Pending Shifts', _pendingTasks.toString(), Icons.assignment_late_outlined, AppTheme.accentOrange),
                ],
              );
            }
          ),
          
          const SizedBox(height: 48),
          
          // Quick Actions Header
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Actions Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Responsive columns for actions
              int columns = width > 1200 ? 4 : (width > 800 ? 3 : (width > 600 ? 2 : 1));
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5, // Wide, rectangular cards
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.borderGray),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.backgroundCanvas,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryPurple, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.borderGray),
            ],
          ),
        ),
      ),
    );
  }
}
"""
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("Successfully rewritten lib/screens/admin_overview_view.dart with new UI.")

if __name__ == "__main__":
    refactor_quick_actions()