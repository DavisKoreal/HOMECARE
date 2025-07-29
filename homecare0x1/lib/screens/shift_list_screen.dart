import 'package:flutter/material.dart';
// import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart'; // Ensure ModernButton is imported
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'admin_calendar_screen.dart';

class ShiftListScreen extends StatefulWidget {
  final DateTime selectedDay;

  const ShiftListScreen({super.key, required this.selectedDay});

  @override
  State<ShiftListScreen> createState() => _ShiftListScreenState();
}

class _ShiftListScreenState extends State<ShiftListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Shift> _getFilteredShifts(ShiftAssignmentProvider provider) {
    final shifts = provider.allShifts.where((shift) {
      final shiftDay = DateTime(
          shift.startTime.year, shift.startTime.month, shift.startTime.day);
      return isSameDay(shiftDay, widget.selectedDay);
    }).toList();

    return shifts.where((shift) {
      final matchesSearch = _searchQuery.isEmpty ||
          shift.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (shift.caregiverName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesFilter =
          _selectedFilter == 'All' || shift.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'pending', 'in_session', 'completed'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by ID, client, or caregiver...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> _showShiftDetailsDialog(Shift shift) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Shift Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shift ID: ${shift.id}'),
              Text('Client: ${shift.clientName} (ID: ${shift.clientId})'),
              Text(
                  'Start: ${DateFormat('h:mm a, MMM d').format(shift.startTime)}'),
              Text('End: ${DateFormat('h:mm a, MMM d').format(shift.endTime)}'),
              Text('Caregiver: ${shift.caregiverName ?? 'Unassigned'}'),
              Text('Status: ${shift.status}'),
              Text(
                  'Location: ${shift.location != null ? '(${shift.location!.latitude}, ${shift.location!.longitude})' : 'Not set'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (shift.status == 'pending')
            ModernButton(
              text: 'Edit Shift',
              icon: Icons.edit,
              onPressed: () {
                // show message of "navigating to be able to edit shift to be implemented"
                // showDialog(builder: )
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title:
          'Shifts on ${DateFormat('MMMM d, yyyy').format(widget.selectedDay)}',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          final shifts = _getFilteredShifts(provider);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 24),
                shifts.isEmpty
                    ? const Center(child: Text('No shifts found'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shifts.length,
                        itemBuilder: (context, index) {
                          final shift = shifts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppTheme.primaryBlue.withOpacity(0.1),
                                child: Icon(Icons.event,
                                    color: AppTheme.primaryBlue),
                              ),
                              title: Text(shift.clientName),
                              subtitle: Text(
                                '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}\n'
                                'Caregiver: ${shift.caregiverName ?? 'Unassigned'}\n'
                                'Status: ${shift.status}',
                              ),
                              onTap: () => _showShiftDetailsDialog(shift),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
