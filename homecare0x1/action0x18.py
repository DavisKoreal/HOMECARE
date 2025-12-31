import os

def improve_ui_and_fix_overflows():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update Constants with Layout & Colors
    # ---------------------------------------------------------
    print("\n--- Updating lib/constants.dart ---")
    constants_path = os.path.join("lib", "constants.dart")
    
    # Reading existing to keep Routes, appending new constants
    with open(constants_path, "r", encoding="utf-8") as f:
        existing_constants = f.read()

    if "class LayoutConstants" not in existing_constants:
        new_constants = """

// UI Layout Breakpoints & Spacing
class LayoutConstants {
  static const double desktopBreakpoint = 1200.0;
  static const double tabletBreakpoint = 800.0;
  
  static const double defaultPadding = 24.0;
  static const double cardRadius = 16.0;
  static const double smallRadius = 8.0;
}

// Brand Color Palette
class AppColors {
  static const Color royalPurple = Color(0xFF5C42BD); // Primary Brand
  static const Color softLavender = Color(0xFFE8EAF6); // Secondary Bg
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFFAB00);
  static const Color errorRed = Color(0xFFD50000);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
}
"""
        # Insert before the last closing brace or just append if simpler. 
        # Actually, constants.dart usually just has classes. We append to end.
        with open(constants_path, "a", encoding="utf-8") as f:
            f.write(new_constants)
        print("Added LayoutConstants and AppColors to constants.dart")

    # ---------------------------------------------------------
    # 2. Refactor Admin Overview (Better Cards + Overflow Fix)
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_overview_view.dart ---")
    overview_path = os.path.join("lib", "screens", "admin_overview_view.dart")
    
    overview_content = """import 'package:flutter/material.dart';
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
"""
    with open(overview_path, "w", encoding="utf-8") as f:
        f.write(overview_content)
    print("Redesigned admin_overview_view.dart (Royal Purple Theme).")


    # ---------------------------------------------------------
    # 3. Fix Shift Assignment Overflow & Style
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/shift_assignment_screen.dart ---")
    shift_path = os.path.join("lib", "screens", "shift_assignment_screen.dart")
    
    # Reading file to inject fixes logic (re-using the structure but with safe layout)
    # We will overwrite with a version that uses `LayoutBuilder` for the Stats row
    # and consistent Styling with the Overview page.
    
    shift_content = """import 'package:flutter/material.dart';
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
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  
  List<Caregiver> _availableCaregivers = [];
  List<Shift> _allShifts = [];
  bool _isLoading = true;

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
      final matchesSearch = shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            (shift.caregiverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Requests': return shift.status == 'request';
        case 'Pending': return shift.status == 'pending';
        case 'Completed': return shift.status == 'completed';
        case 'Unassigned': return shift.caregiverId == null;
        case 'Today': return shift.startTime.year == now.year && shift.startTime.day == now.day;
        case 'This Week': return shift.startTime.difference(now).inDays >= 0 && shift.startTime.difference(now).inDays <= 7;
        case 'This Month': return shift.startTime.year == now.year && shift.startTime.month == now.month;
        default: return true;
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
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caregiver assigned successfully'), backgroundColor: AppColors.successGreen)
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _allShifts.where((s) => s.status == 'request' || s.caregiverId == null).length;
    final availableStaff = _availableCaregivers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Shift Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // --- Stats Section (Responsive Layout to fix Overflow) ---
          LayoutBuilder(
            builder: (context, constraints) {
              // If width < 900px, stack them vertically or 2x2. 
              // Using a simple column for narrow screens fixes the RenderFlex error.
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _buildStatCard('Pending Needs', pendingCount.toString(), Icons.assignment_late, AppColors.warningOrange),
                    const SizedBox(height: 12),
                    _buildStatCard('Available Staff', availableStaff.toString(), Icons.people_alt, AppColors.successGreen),
                    const SizedBox(height: 12),
                    _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_month, AppColors.royalPurple),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending Needs', pendingCount.toString(), Icons.assignment_late, AppColors.warningOrange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Available Staff', availableStaff.toString(), Icons.people_alt, AppColors.successGreen)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_month, AppColors.royalPurple)),
                  ],
                );
              }
            }
          ),
          
          const SizedBox(height: 32),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LayoutConstants.smallRadius),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(0),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderGray),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      items: ['All', 'Requests', 'Pending', 'Completed', 'Unassigned', 'Today', 'This Week']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedFilter = val!),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Table
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
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      dataTextStyle: const TextStyle(color: AppColors.textDark),
                    ),
                  ),
                  child: PaginatedDataTable(
                    header: null,
                    rowsPerPage: 10,
                    columns: const [
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Assigned')),
                      DataColumn(label: Text('Action')),
                    ],
                    source: _ShiftDataSource(_filteredShifts, context, _showAssignmentDialog),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // Improved Stat Card to match Admin Overview
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
            ],
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
    final needsAction = shift.caregiverId == null || shift.status == 'request';

    return DataRow(cells: [
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('MMM d').format(shift.startTime), style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(DateFormat('h:mm a').format(shift.startTime), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      )),
      DataCell(Text(shift.clientName)),
      DataCell(_buildStatusChip(shift.status)),
      DataCell(Text(shift.caregiverName ?? '-', style: TextStyle(color: shift.caregiverName == null ? AppColors.textLight : AppColors.textDark))),
      DataCell(
        needsAction
          ? ElevatedButton(
              onPressed: () => onAssign(shift),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Assign'),
            )
          : const Text('No Action', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.textLight;
    if (status == 'completed') color = AppColors.successGreen;
    if (status == 'pending') color = AppColors.warningOrange;
    if (status == 'request') color = AppColors.errorRed;

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
            Text('Assigning for ${widget.shift.clientName}', style: const TextStyle(color: AppColors.textLight)),
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
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
"""
    with open(shift_path, "w", encoding="utf-8") as f:
        f.write(shift_content)
    print("Fixed Overflow in Shift Assignment and applied Royal Purple theme.")

if __name__ == "__main__":
    improve_ui_and_fix_overflows()