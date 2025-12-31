import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:provider/provider.dart';

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
          _pendingTasks = shiftProvider.shifts.where((shift) => shift.status == 'pending' || shift.status == 'request').length;
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
    if (_errorMessage != null) return Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.errorRed)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Welcome back, ${user?.name ?? "Admin"}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is the latest activity for your team.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // --- Key Metrics Grid ---
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Responsive: 3 cols on large, 2 on medium, 1 on small
              int columns = width > 1000 ? 3 : (width > 600 ? 2 : 1);
              // Aspect Ratio: Lower ratio = Taller card (Fixes overflow)
              double aspectRatio = width > 1000 ? 1.6 : (width > 600 ? 1.4 : 1.8);
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspectRatio,
                children: [
                  _buildStatCard(
                    title: 'Active Recipients',
                    value: _activeClients.toString(),
                    icon: Icons.people_alt_rounded,
                    color: AppColors.royalPurple,
                    trend: '+ New this week',
                  ),
                  _buildStatCard(
                    title: 'Care Staff',
                    value: _activeCaregivers.toString(),
                    icon: Icons.medical_services_rounded,
                    color: Colors.blueAccent,
                    trend: 'Fully staffed',
                  ),
                  _buildStatCard(
                    title: 'Pending Requests',
                    value: _pendingTasks.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.warningOrange,
                    trend: 'Requires attention',
                    isAlert: _pendingTasks > 0,
                  ),
                ],
              );
            }
          ),
          
          const SizedBox(height: 48),
          
          // --- Quick Actions Header ---
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // --- Quick Actions Grid ---
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = width > 1100 ? 4 : (width > 800 ? 3 : (width > 500 ? 2 : 1));
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2, // Wide button style
                children: [
                  _buildActionCard('New Shift', Icons.add_circle_outline, () => widget.onNavigate(Routes.adminInitiateShift)),
                  _buildActionCard('Add Client', Icons.person_add_outlined, () => widget.onNavigate(Routes.adminAddClient)),
                  _buildActionCard('Add Staff', Icons.group_add_outlined, () => widget.onNavigate(Routes.adminAddCaregiver)),
                  _buildActionCard('Approvals', Icons.verified_user_outlined, () => widget.onNavigate(Routes.adminCaregiverApproval)),
                  _buildActionCard('Schedule', Icons.calendar_month_outlined, () => widget.onNavigate(Routes.adminCalendar)),
                  _buildActionCard('Audit Logs', Icons.security_outlined, () => widget.onNavigate(Routes.auditLog)),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildStatCard({
    required String title, 
    required String value, 
    required IconData icon, 
    required Color color, 
    String? trend,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
        border: Border.all(
          color: isAlert ? color.withOpacity(0.5) : AppTheme.borderGray, 
          width: isAlert ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (isAlert)
                Icon(Icons.circle, color: color, size: 12),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36, 
                  fontWeight: FontWeight.w800, 
                  color: AppColors.textDark
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight
                ),
              ),
            ],
          ),
          if (trend != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCanvas,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trend,
                style: TextStyle(
                  fontSize: 12, 
                  color: color, 
                  fontWeight: FontWeight.w600
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LayoutConstants.smallRadius),
        side: const BorderSide(color: AppTheme.borderGray),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LayoutConstants.smallRadius),
        hoverColor: AppColors.royalPurple.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textLight, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
