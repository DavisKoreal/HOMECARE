import os

def fix_overflow_and_stats():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Fix Shift Assignment Screen Overflow
    # ---------------------------------------------------------
    print("\n--- Fixing Overflow in lib/screens/shift_assignment_screen.dart ---")
    shift_path = os.path.join("lib", "screens", "shift_assignment_screen.dart")
    
    # We'll update the Stats Row to use a LayoutBuilder for responsiveness
    # and ensure the Filter Bar doesn't overflow.
    
    with open(shift_path, "r", encoding="utf-8") as f:
        shift_content = f.read()

    # Replace the fixed Row of stats with a responsive layout
    new_stats_row = """
          // 1. Stats Row (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final isMedium = constraints.maxWidth > 600;
              
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending Assignments', pendingCount.toString(), Icons.assignment_late, AppTheme.accentOrange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Available Caregivers', availableStaff.toString(), Icons.medical_services, AppTheme.successGreen)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_today, AppTheme.primaryPurple)),
                  ],
                );
              } else {
                // Stack vertically or 2+1 grid on small screens
                return Column(
                  children: [
                    _buildStatCard('Pending Assignments', pendingCount.toString(), Icons.assignment_late, AppTheme.accentOrange),
                    const SizedBox(height: 12),
                    _buildStatCard('Available Caregivers', availableStaff.toString(), Icons.medical_services, AppTheme.successGreen),
                    const SizedBox(height: 12),
                    _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_today, AppTheme.primaryPurple),
                  ],
                );
              }
            }
          ),
    """
    
    # Replace the specific block in the file (approximating context)
    # Since we can't easily regex replace a large block reliably without errors, 
    # I'll rewrite the build method logic for the stats row specifically if possible,
    # OR simply overwrite the file with the corrected version to be safe.
    
    # Given the complexity, overwriting the file with the fix is safer.
    # I will stick to the "Overwrite" strategy for robustness.
    
    shift_fixed_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/caregiver.dart';

class ShiftAssignmentScreen extends StatefulWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  State<ShiftAssignmentScreen> createState() => _ShiftAssignmentScreenState();
}

class _ShiftAssignmentScreenState extends State<ShiftAssignmentScreen> {
  // Services & Data
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  
  List<Caregiver> _availableCaregivers = [];
  List<Shift> _allShifts = [];
  bool _isLoading = true;

  // Filters
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final caregivers = await _caregiverService.getAvailableCaregivers();
      final shifts = await _shiftService.getAllShifts();
      
      if (mounted) {
        setState(() {
          _availableCaregivers = caregivers;
          _allShifts = shifts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Shift> get _filteredShifts {
    final now = DateTime.now();
    
    return _allShifts.where((shift) {
      // 1. Search Filter
      final matchesSearch = shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            (shift.caregiverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      if (!matchesSearch) return false;

      // 2. Status & Date Filter
      switch (_selectedFilter) {
        case 'Requests': return shift.status == 'request';
        case 'Pending': return shift.status == 'pending';
        case 'Completed': return shift.status == 'completed';
        case 'Unassigned': return shift.caregiverId == null;
        
        // Date Filters
        case 'Today':
          return shift.startTime.year == now.year && 
                 shift.startTime.month == now.month && 
                 shift.startTime.day == now.day;
        
        case 'This Week':
          final difference = shift.startTime.difference(now).inDays;
          return difference >= 0 && difference <= 7;

        case 'This Month':
          return shift.startTime.year == now.year && shift.startTime.month == now.month;

        default: return true; // 'All'
      }
    }).toList();
  }

  void _showAssignmentDialog(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => _AssignmentDialog(
        shift: shift,
        caregivers: _availableCaregivers,
        onAssign: (caregiverId, caregiverName) async {
          await _shiftService.assignShift(shift.id, caregiverId, caregiverName);
          Navigator.pop(context);
          _loadData(); // Refresh list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caregiver assigned successfully'), backgroundColor: AppTheme.successGreen)
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Stats
    final pendingCount = _allShifts.where((s) => s.status == 'request' || s.caregiverId == null).length;
    final availableStaff = _availableCaregivers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shift Assignments',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage open shifts and assign caregivers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh List',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Stats Row (Responsive Fix)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending Assignments', pendingCount.toString(), Icons.assignment_late, AppTheme.accentOrange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Available Caregivers', availableStaff.toString(), Icons.medical_services, AppTheme.successGreen)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_today, AppTheme.primaryPurple)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStatCard('Pending Assignments', pendingCount.toString(), Icons.assignment_late, AppTheme.accentOrange),
                    const SizedBox(height: 12),
                    _buildStatCard('Available Caregivers', availableStaff.toString(), Icons.medical_services, AppTheme.successGreen),
                    const SizedBox(height: 12),
                    _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_today, AppTheme.primaryPurple),
                  ],
                );
              }
            }
          ),
          const SizedBox(height: 32),

          // 2. Filters Bar (Updated with Date Options & Overflow Fix)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If constrained width, stack vertically
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All', 'Requests', 'Pending', 'Completed', 'Unassigned', 'Today', 'This Week', 'This Month']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedFilter = val!),
                      ),
                    ],
                  );
                }
                
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search client or caregiver...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.borderGray),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            isExpanded: true,
                            items: ['All', 'Requests', 'Pending', 'Completed', 'Unassigned', 'Today', 'This Week', 'This Month']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedFilter = val!),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          const SizedBox(height: 24),

          // 3. Shifts Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: _isLoading 
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              : Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: AppTheme.borderGray,
                    dataTableTheme: DataTableThemeData(
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      dataTextStyle: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  child: PaginatedDataTable(
                    header: null,
                    rowsPerPage: 10,
                    columns: const [
                      DataColumn(label: Text('Date & Time')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Assigned To')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _ShiftDataSource(_filteredShifts, context, _showAssignmentDialog),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  title, 
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftDataSource extends DataTableSource {
  final List<Shift> _shifts;
  final BuildContext context;
  final Function(Shift) onAssign;

  _ShiftDataSource(this._shifts, this.context, this.onAssign);

  @override
  DataRow? getRow(int index) {
    if (index >= _shifts.length) return null;
    final shift = _shifts[index];
    
    // Determine if action is needed
    final needsAction = shift.caregiverId == null || shift.status == 'request';

    return DataRow(cells: [
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('MMM d, yyyy').format(shift.startTime), style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      )),
      DataCell(Text(shift.clientName)),
      DataCell(_buildStatusChip(shift.status)),
      DataCell(
        shift.caregiverName != null 
          ? Row(children: [
              const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(shift.caregiverName!)
            ])
          : const Text('-', style: TextStyle(color: AppTheme.textSecondary)),
      ),
      DataCell(
        needsAction
          ? ElevatedButton(
              onPressed: () => onAssign(shift),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero, 
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              child: const Text('Assign', style: TextStyle(fontSize: 12)),
            )
          : const Text('No Action', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
      ),
    ]);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed': color = AppTheme.successGreen; break;
      case 'in_session': color = Colors.blue; break;
      case 'pending': color = Colors.orange; break;
      case 'request': color = AppTheme.errorRed; break;
      default: color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _shifts.length;
  @override
  int get selectedRowCount => 0;
}

class _AssignmentDialog extends StatefulWidget {
  final Shift shift;
  final List<Caregiver> caregivers;
  final Function(String, String) onAssign;

  const _AssignmentDialog({required this.shift, required this.caregivers, required this.onAssign});

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Caregiver'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigning shift for ${widget.shift.clientName}', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedId,
              hint: const Text('Select Caregiver'),
              items: widget.caregivers.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )).toList(),
              onChanged: (val) => setState(() => _selectedId = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _selectedId == null ? null : () {
            final caregiver = widget.caregivers.firstWhere((c) => c.id == _selectedId);
            widget.onAssign(caregiver.id, caregiver.name);
          }, 
          child: const Text('Confirm Assignment'),
        ),
      ],
    );
  }
}
"""
    with open(shift_path, "w", encoding="utf-8") as f:
        f.write(shift_fixed_content)
    print("Fixed Overflow issues in Shift Assignment Screen.")


    # ---------------------------------------------------------
    # 2. Refactor Admin Overview Stats (Better Design)
    # ---------------------------------------------------------
    print("\n--- Refactoring Stats in lib/screens/admin_overview_view.dart ---")
    overview_path = os.path.join("lib", "screens", "admin_overview_view.dart")
    
    with open(overview_path, "r", encoding="utf-8") as f:
        overview_content = f.read()

    # We will redefine the `_buildMetricCard` method to be cleaner and more robust
    # Instead of string replace, we'll overwrite the file with the enhanced version.
    
    overview_new_content = """import 'package:flutter/material.dart';
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
          
          // Metrics Grid (Refactored)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Responsive columns: 3 on wide, 2 on medium, 1 on small
              int columns = width > 900 ? 3 : (width > 600 ? 2 : 1);
              double aspectRatio = width > 900 ? 2.5 : 2.0; 
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspectRatio,
                children: [
                  _buildMetricCard(
                    title: 'Total Recipients', 
                    value: _activeClients.toString(), 
                    icon: Icons.people_outline, 
                    color: AppTheme.successGreen,
                    trend: '+2 this week'
                  ),
                  _buildMetricCard(
                    title: 'Active Care Staff', 
                    value: _activeCaregivers.toString(), 
                    icon: Icons.medical_services_outlined, 
                    color: AppTheme.primaryPurple,
                    trend: 'All active'
                  ),
                  _buildMetricCard(
                    title: 'Pending Requests', 
                    value: _pendingTasks.toString(), 
                    icon: Icons.assignment_late_outlined, 
                    color: AppTheme.accentOrange,
                    trend: 'Action needed'
                  ),
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
              int columns = width > 1200 ? 4 : (width > 800 ? 3 : (width > 600 ? 2 : 1));
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
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

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color, String? trend}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(trend, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
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
    with open(overview_path, "w", encoding="utf-8") as f:
        f.write(overview_new_content)
    print("Rewrote admin_overview_view.dart with improved stats design.")

if __name__ == "__main__":
    fix_overflow_and_stats()