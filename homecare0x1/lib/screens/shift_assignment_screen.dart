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
          const SizedBox(height: 8),
          Text(
            'Monitor shift status and assign staff efficiently.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 32),

          // --- Stats Section (Updated to Horizontal Card Layout) ---
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Responsive: Stack on mobile (<900), Row on Desktop
              if (width < 900) {
                return Column(
                  children: [
                    _buildStatCard('Pending Needs', pendingCount.toString(), Icons.assignment_late_outlined, AppColors.warningOrange),
                    const SizedBox(height: 12),
                    _buildStatCard('Available Staff', availableStaff.toString(), Icons.people_alt_outlined, AppColors.successGreen),
                    const SizedBox(height: 12),
                    _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_month_outlined, AppColors.royalPurple),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending Needs', pendingCount.toString(), Icons.assignment_late_outlined, AppColors.warningOrange)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Available Staff', availableStaff.toString(), Icons.people_alt_outlined, AppColors.successGreen)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Total Shifts', _allShifts.length.toString(), Icons.calendar_month_outlined, AppColors.royalPurple)),
                  ],
                );
              }
            }
          ),
          
          const SizedBox(height: 48),

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
                      hintText: 'Search client or staff...',
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
                      DataColumn(label: Text('Assigned Staff')),
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

  // --- Optimized Stat Card (Horizontal Layout) ---
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Left
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          // Text Right (Vertical Stack)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Hug content vertically
              children: [
                Text(
                  value, 
                  style: const TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800, 
                    color: AppColors.textDark,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title, 
                  style: const TextStyle(
                    fontSize: 13, 
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500
                  ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Assign'),
            )
          : const Text('No Action', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontStyle: FontStyle.italic)),
      ),
    ]);
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.textLight;
    if (status == 'completed') color = AppColors.successGreen;
    if (status == 'pending') color = AppColors.warningOrange;
    if (status == 'request') color = AppColors.errorRed;
    if (status == 'in_session') color = Colors.blue;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
