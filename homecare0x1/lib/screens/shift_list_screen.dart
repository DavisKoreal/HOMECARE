import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'admin_calendar_screen.dart';
import 'package:homecare0x1/models/shift.dart';

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
    final filters = ['All', 'pending', 'in_session', 'completed', 'request'];

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
              backgroundColor: AppTheme.neutral100,
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.neutral600,
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
        color: AppTheme.neutral100,
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
          hintText: 'Search shifts, clients, or caregivers...',
          prefixIcon: Icon(Icons.search, color: AppTheme.neutral600),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear, color: AppTheme.neutral600),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> _showEditShiftDialog(Shift shift) async {
    DateTime? startTime = shift.startTime;
    DateTime? endTime = shift.endTime;
    String? selectedCaregiverId = shift.caregiverId;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Shift'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Caregiver (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCaregiverId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...provider.availableCaregivers
                            .map((caregiver) => DropdownMenuItem<String>(
                                  value: caregiver.id,
                                  child: Text(caregiver.name),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCaregiverId = value;
                          errorMessage = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ModernButton(
                  text: 'Select Start Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime!),
                      );
                      if (time != null) {
                        setState(() {
                          startTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          endTime = startTime!.add(const Duration(hours: 2));
                          errorMessage = null;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                ModernButton(
                  text: 'Select End Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime!),
                      );
                      if (time != null) {
                        setState(() {
                          endTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          errorMessage = null;
                        });
                      }
                    }
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (startTime == null || endTime == null) {
                setState(() {
                  errorMessage = 'Please select both start and end times';
                });
                return;
              }
              if (startTime!.isBefore(DateTime.now())) {
                setState(() {
                  errorMessage = 'Start time must be in the future';
                });
                return;
              }
              if (startTime!.isAfter(endTime!)) {
                setState(() {
                  errorMessage = 'Start time must be before end time';
                });
                return;
              }
              try {
                final shiftProvider = Provider.of<ShiftAssignmentProvider>(
                    context,
                    listen: false);
                final caregiverName = selectedCaregiverId != null
                    ? shiftProvider.availableCaregivers
                        .firstWhere((c) => c.id == selectedCaregiverId)
                        .name
                    : null;
                await shiftProvider.updateShift(
                  shiftId: shift.id,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                  caregiverId: selectedCaregiverId,
                  caregiverName: caregiverName,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift updated successfully')),
                );
              } catch (e) {
                setState(() {
                  errorMessage = e.toString();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update Shift'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title:
          'Shifts for ${DateFormat('MMM d, yyyy').format(widget.selectedDay)}',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacementNamed(
        context,
        Routes.adminCalendar,
        arguments: widget.selectedDay,
      ),
      body: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          final filteredShifts = _getFilteredShifts(provider);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                _buildSearchBar(),

                // Filter chips
                _buildFilterChips(),

                const SizedBox(height: 24),

                // Shifts List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Shifts (${filteredShifts.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                filteredShifts.isEmpty
                    ? Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: AppTheme.neutral600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No shifts for this day'
                                    : 'No shifts match your search',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredShifts.length,
                        itemBuilder: (context, index) {
                          final shift = filteredShifts[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neutral600.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.getStatusColor(shift.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event,
                                  color: AppTheme.getStatusColor(shift.status),
                                ),
                              ),
                              title: Text(
                                shift.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: AppTheme.neutral600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                                        style: TextStyle(
                                          color: AppTheme.neutral600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (shift.caregiverName != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: AppTheme.neutral600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          shift.caregiverName!,
                                          style: TextStyle(
                                            color: AppTheme.neutral600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.getStatusColor(shift.status)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      shift.status,
                                      style: TextStyle(
                                        color: AppTheme.getStatusColor(
                                            shift.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryBlue,
                                ),
                                onPressed: () => _showEditShiftDialog(shift),
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
