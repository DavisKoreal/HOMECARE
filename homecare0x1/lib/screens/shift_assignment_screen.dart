import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShiftAssignmentScreen extends StatefulWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  State<ShiftAssignmentScreen> createState() => _ShiftAssignmentScreenState();
}

class _ShiftAssignmentScreenState extends State<ShiftAssignmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isAssigning = false;
  String? _selectedShiftId;
  String? _selectedCaregiverId;
  bool _showCaregiverDetails = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateShiftDialog() async {
    final clientController = TextEditingController();
    String? selectedClientId;
    String? selectedCaregiverId;
    DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime? endTime = startTime.add(const Duration(hours: 2));
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Shift'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ShiftAssignmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedClientId,
                      items: provider.clients
                          .map((client) => DropdownMenuItem<String>(
                                value: client.id,
                                child: Text(client.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClientId = value;
                          clientController.text = value != null
                              ? provider.clients
                                  .firstWhere((c) => c.id == value)
                                  .name
                              : '';
                          errorMessage = null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
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
              if (selectedClientId == null) {
                setState(() {
                  errorMessage = 'Please select a client';
                });
                return;
              }
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
                final clientName = shiftProvider.clients
                    .firstWhere((c) => c.id == selectedClientId)
                    .name;
                final caregiverName = selectedCaregiverId != null
                    ? shiftProvider.availableCaregivers
                        .firstWhere((c) => c.id == selectedCaregiverId)
                        .name
                    : null;
                await shiftProvider.addShift(
                  clientId: selectedClientId!,
                  clientName: clientName,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                  caregiverId: selectedCaregiverId,
                  caregiverName: caregiverName,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift created successfully')),
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
            child: const Text('Create Shift'),
          ),
        ],
      ),
    );
  }

  void _assignCaregiver(BuildContext context, Shift shift) {
    final provider =
        Provider.of<ShiftAssignmentProvider>(context, listen: false);
    final availableCaregivers = provider.availableCaregivers;

    setState(() {
      _selectedShiftId = shift.id;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.neutral600.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assign Caregiver',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Client: ${shift.clientName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.neutral600,
                                ),
                          ),
                          Text(
                            DateFormat('MMM d, h:mm a').format(shift.startTime),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedShiftId = null;
                          _selectedCaregiverId = null;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Caregivers list
              Expanded(
                child: availableCaregivers.isEmpty
                    ? _buildEmptyState(
                        'No available caregivers', Icons.person_off)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableCaregivers.length,
                        itemBuilder: (context, index) {
                          final caregiver = availableCaregivers[index];
                          final isSelected =
                              _selectedCaregiverId == caregiver.id;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.neutral600.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? AppTheme.primaryBlue.withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.neutral100,
                                child: Icon(
                                  Icons.person,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.neutral600,
                                ),
                              ),
                              title: Text(
                                caregiver.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected ? AppTheme.primaryBlue : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppTheme.successGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Available'),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Experience: 3+ years',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryBlue,
                                    )
                                  : const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                              onTap: () {
                                setModalState(() {
                                  _selectedCaregiverId =
                                      isSelected ? null : caregiver.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),

              // Action buttons
              if (_selectedCaregiverId != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    border: Border(
                      top: BorderSide(
                          color: AppTheme.neutral600.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCaregiverId = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isAssigning
                              ? null
                              : () async {
                                  setState(() {
                                    _isAssigning = true;
                                  });

                                  final selectedCaregiver =
                                      availableCaregivers.firstWhere(
                                          (c) => c.id == _selectedCaregiverId);

                                  // Simulate assignment delay
                                  await Future.delayed(
                                      const Duration(milliseconds: 800));

                                  try {
                                    provider.assignShift(
                                      shift.id,
                                      selectedCaregiver.id,
                                      selectedCaregiver.name,
                                    );

                                    setState(() {
                                      _isAssigning = false;
                                      _selectedShiftId = null;
                                      _selectedCaregiverId = null;
                                    });

                                    Navigator.pop(context);

                                    // Show success animation
                                    _showSuccessSnackBar(
                                      'Successfully assigned ${selectedCaregiver.name} to ${shift.clientName}\'s shift',
                                    );
                                  } catch (e) {
                                    setState(() {
                                      _isAssigning = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: AppTheme.errorRed,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAssigning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Assign Caregiver',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.neutral600,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral600,
                ),
          ),
        ],
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
          hintText: 'Search caregivers or clients...',
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Urgent', 'Today', 'This Week', 'Requests'];

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

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Consumer<ShiftAssignmentProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Available\nCaregivers',
                  provider.availableCaregivers.length.toString(),
                  Icons.people,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pending\nAssignments',
                  provider.unassignedShifts.length.toString(),
                  Icons.assignment_late,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Shift Assignment',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateShiftDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<ShiftAssignmentProvider>(
            builder: (context, provider, child) {
              final unassignedShifts = provider.unassignedShifts;
              final requestShifts = provider.requestShifts;

              // Combine and filter shifts based on search query and filter
              final allShifts = [...unassignedShifts, ...requestShifts];
              final filteredShifts = allShifts.where((shift) {
                final matchesSearch = _searchQuery.isEmpty ||
                    shift.clientName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                final matchesFilter = _selectedFilter == 'All' ||
                    (_selectedFilter == 'Requests' &&
                        shift.status == 'request') ||
                    (_selectedFilter != 'Requests' &&
                        shift.status != 'request');
                return matchesSearch && matchesFilter;
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats card
                    _buildStatsCard(),

                    // Search bar
                    _buildSearchBar(),

                    // Filter chips
                    _buildFilterChips(),

                    const SizedBox(height: 24),

                    // Available Caregivers Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Caregivers',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppTheme.successGreen.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${provider.availableCaregivers.length}',
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    provider.availableCaregivers.isEmpty
                        ? Container(
                            height: 120,
                            child: _buildEmptyState(
                                'No caregivers available', Icons.person_off),
                          )
                        : Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.availableCaregivers.length,
                              itemBuilder: (context, index) {
                                final caregiver =
                                    provider.availableCaregivers[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.neutral600
                                            .withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundColor: AppTheme.primaryBlue
                                              .withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            color: AppTheme.primaryBlue,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          caregiver.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successGreen
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Available',
                                            style: TextStyle(
                                              color: AppTheme.successGreen,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                    const SizedBox(height: 32),

                    // Unassigned Shifts Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_late,
                            color: AppTheme.accentOrange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kindly assign caregivers to the following pending shifts',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppTheme.accentOrange.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${filteredShifts.length}',
                              style: TextStyle(
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    filteredShifts.isEmpty
                        ? Container(
                            height: 200,
                            child: _buildEmptyState(
                              _searchQuery.isNotEmpty
                                  ? 'No shifts match your search'
                                  : 'No unassigned shifts',
                              Icons.assignment_turned_in,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredShifts.length,
                            itemBuilder: (context, index) {
                              final shift = filteredShifts[index];
                              final isSelected = _selectedShiftId == shift.id;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.neutral600.withOpacity(0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.neutral600.withOpacity(0.08),
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
                                      color: AppTheme.accentOrange
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.event,
                                      color: AppTheme.accentOrange,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            DateFormat('MMM d, h:mm a')
                                                .format(shift.startTime),
                                            style: TextStyle(
                                              color: AppTheme.neutral600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: shift.status == 'request'
                                              ? AppTheme.errorRed
                                                  .withOpacity(0.1)
                                              : AppTheme.errorRed
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          shift.status == 'request'
                                              ? 'Request'
                                              : 'Unassigned',
                                          style: TextStyle(
                                            color: shift.status == 'request'
                                                ? AppTheme.errorRed
                                                : AppTheme.errorRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppTheme.primaryBlue,
                                    size: 18,
                                  ),
                                  onTap: () => _assignCaregiver(context, shift),
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
        ),
      ),
    );
  }
}
