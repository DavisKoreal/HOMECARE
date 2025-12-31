import 'package:flutter/material.dart';
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
