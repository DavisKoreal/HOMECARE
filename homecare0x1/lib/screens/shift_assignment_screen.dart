import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/actions/overlay.dart';

// Widget for managing shift assignments in the homecare application.
class ShiftAssignmentScreen extends StatefulWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  State<ShiftAssignmentScreen> createState() => _ShiftAssignmentScreenState();
}

// State class for ShiftAssignmentScreen, handling UI and logic for shift assignments.
class _ShiftAssignmentScreenState extends State<ShiftAssignmentScreen>
    with TickerProviderStateMixin {
  // Animation controller for fade-in effect of the screen content.
  late AnimationController _fadeController;
  // Animation controller for slide-in effect of the content.
  late AnimationController _slideController;
  // Animation for fading in the UI from transparent to opaque.
  late Animation<double> _fadeAnimation;
  // Animation for sliding the content into view from a slight offset.
  late Animation<Offset> _slideAnimation;

  // State variables for filtering, searching, and managing assignments.
  String _selectedFilter = 'All'; // Currently selected filter for shifts.
  String _searchQuery = ''; // Current search query for filtering shifts.
  bool _isAssigning = false; // Flag to indicate if an assignment is in progress.
  String? _selectedShiftId; // ID of the currently selected shift for assignment.
  String? _selectedCaregiverId; // ID of the currently selected caregiver.

  // Text controller for the search bar input.
  final TextEditingController _searchController = TextEditingController();
  // Instance of FirebaseShiftService for Firestore data operations.
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;
  // Instance of OverlayUtils for displaying notification overlays.
  late OverlayUtils _overlayUtils;

  // Lists to store fetched data from Firestore.
  List<Caregiver> _availableCaregivers = []; // List of available caregivers.
  List<Client> _clients = []; // List of clients.
  List<Shift> _allShifts = []; // List of all shifts.

  @override
  void initState() {
    super.initState();
    // Initialize animations and overlay utility, and log initialization.
    _initializeAnimations();
    _overlayUtils = OverlayUtils(); // Initialize OverlayUtils for notifications.
    print('Shift Assignment Screen Initialized');
    // Fetch initial data when the screen loads.
    _fetchInitialData();
  }

  // Initializes animation controllers and their corresponding animations.
  void _initializeAnimations() {
    // Set up fade animation controller with an 800ms duration.
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Set up slide animation controller with a 600ms duration.
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Define fade animation from 0.0 (invisible) to 1.0 (fully visible).
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Define slide animation from a slight downward offset to no offset.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start both animations.
    _fadeController.forward();
    _slideController.forward();
  }

  // Fetches initial data (caregivers, clients, shifts) from Firestore.
  Future<void> _fetchInitialData() async {
    try {
      // Fetch caregivers, clients, and shifts concurrently.
      final caregivers = await _shiftService.getAvailableCaregivers();
      final clients = await _shiftService.getAllClients();
      final shifts = await _shiftService.getAllShifts();
      setState(() {
        // Update state with fetched data.
        _availableCaregivers = caregivers;
        _clients = clients;
        _allShifts = shifts;
      });
    } catch (e) {
      // Log error and show error notification if data fetching fails.
      print('Error fetching initial data: $e');
      _overlayUtils.showOverlay(context, 'Failed to load data: $e', isError: true);
    }
  }

  // Cleans up resources when the widget is disposed.
  @override
  void dispose() {
    // Dispose of animation controllers and text controller.
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    // Clean up OverlayUtils to remove any active overlays.
    _overlayUtils.dispose();
    super.dispose();
  }

  // Refreshes data from Firestore and updates the UI.
  Future<void> _refreshData(BuildContext context) async {
    try {
      // Show a loading notification overlay.
      _overlayUtils.showOverlay(context, 'Refreshing data...');

      // Fetch all data concurrently using Future.wait.
      final results = await Future.wait([
        _shiftService.getAvailableCaregivers(),
        _shiftService.getAllClients(),
        _shiftService.getAllShifts(),
      ]);

      setState(() {
        // Update state with refreshed data.
        _availableCaregivers = results[0] as List<Caregiver>;
        _clients = results[1] as List<Client>;
        _allShifts = results[2] as List<Shift>;
      });

      // Show success notification after refreshing.
      _overlayUtils.showOverlay(context, 'Data refreshed successfully');
    } catch (e) {
      // Show error notification if refreshing fails.
      _overlayUtils.showOverlay(context, 'Failed to refresh data: $e', isError: true);
    }
  }

  // Shows a dialog for creating a new shift.
  Future<void> _showCreateShiftDialog() async {
    // Controllers and variables for the dialog inputs.
    final clientController = TextEditingController();
    String? selectedClientId;
    String? selectedCaregiverId;
    DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime? endTime = startTime.add(const Duration(hours: 2));
    String? errorMessage;

    // Display the dialog for creating a new shift.
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Apply rounded corners for a modern look.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Shift'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown for selecting a client.
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Client',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedClientId,
                  items: _clients
                      .map((client) => DropdownMenuItem<String>(
                            value: client.id,
                            child: Text(client.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClientId = value;
                      clientController.text = value != null
                          ? _clients.firstWhere((c) => c.id == value).name
                          : '';
                      errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown for selecting a caregiver (optional).
                DropdownButtonFormField<String>(
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
                    ..._availableCaregivers
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
                ),
                const SizedBox(height: 16),
                // Button to select start date and time.
                ModernButton(
                  text: 'Select Start Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    // Show date picker followed by time picker.
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
                // Button to select end date and time.
                ModernButton(
                  text: 'Select End Time',
                  icon: Icons.access_time,
                  onPressed: () async {
                    // Show date picker followed by time picker.
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
                // Display error message if validation fails.
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
          // Cancel button to dismiss the dialog.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Button to create the shift.
          ElevatedButton(
            onPressed: () async {
              // Validate inputs before creating the shift.
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
                // Retrieve client and caregiver names.
                final clientName = _clients
                    .firstWhere((c) => c.id == selectedClientId)
                    .name;
                final caregiverName = selectedCaregiverId != null
                    ? _availableCaregivers
                        .firstWhere((c) => c.id == selectedCaregiverId)
                        .name
                    : null;
                // Add the shift using FirebaseShiftService.
                final result = await _shiftService.addShift(
                  clientId: selectedClientId!,
                  clientName: clientName,
                  startTime: startTime!,
                  endTime: endTime!,
                  context: context,
                  caregiverId: selectedCaregiverId,
                  caregiverName: caregiverName,
                );
                if (result == "success") {
                  // Close the dialog and refresh data.
                  Navigator.pop(context);
                  await _fetchInitialData();
                  // Show success notification.
                  _overlayUtils.showOverlay(context, 'Shift created successfully');
                } else {
                  setState(() {
                    errorMessage = 'Failed to create shift';
                  });
                  _overlayUtils.showOverlay(context, "Shift has not been created. Kindly try again. ")
                }
              } catch (e) {
                // Update error message in the dialog.
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

  // Shows a modal bottom sheet for assigning a caregiver to a shift.
  void _assignCaregiver(BuildContext context, Shift shift) {
    // Set the selected shift ID for assignment.
    setState(() {
      _selectedShiftId = shift.id;
    });

    // Display the modal bottom sheet for caregiver selection.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          // Set height to 70% of the screen height.
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
              // Handle bar for the modal sheet.
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.neutral600.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with shift details and close button.
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
                    // Close button to dismiss the modal.
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
              // List of caregivers or empty state.
              Expanded(
                child: _availableCaregivers.isEmpty
                    ? _buildEmptyState(
                        'No available caregivers at the moment', Icons.person_off)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _availableCaregivers.length,
                        itemBuilder: (context, index) {
                          final caregiver = _availableCaregivers[index];
                          final isSelected = _selectedCaregiverId == caregiver.id;

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
                                  : const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                print('Selected Caregiver: ${caregiver.name}');
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
              // Action buttons for assigning or canceling.
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
                      // Cancel button to clear selection.
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
                      // Button to assign the selected caregiver.
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
                                      _availableCaregivers.firstWhere(
                                          (c) => c.id == _selectedCaregiverId);

                                  try {
                                    // Assign the shift using FirebaseShiftService.
                                    final result = await _shiftService.assignShift(
                                      shift.id,
                                      selectedCaregiver.id,
                                      selectedCaregiver.name,
                                    );

                                    if (result == "success") {
                                      setState(() {
                                        _isAssigning = false;
                                        _selectedShiftId = null;
                                        _selectedCaregiverId = null;
                                      });

                                      // Refresh data after successful assignment.
                                      await _fetchInitialData();

                                      // Close the modal.
                                      Navigator.pop(context);

                                      // Show success notification.
                                      _overlayUtils.showOverlay(context,
                                          'Successfully assigned ${selectedCaregiver.name} to ${shift.clientName}\'s shift');
                                    } else {
                                      throw Exception('Failed to assign shift');
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _isAssigning = false;
                                    });
                                    // Show error notification.
                                    _overlayUtils.showOverlay(
                                        context, e.toString(), isError: true);
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

  // Builds an empty state widget for scenarios with no data.
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

  // Builds the search bar for filtering caregivers or clients.
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
            _searchQuery = value; // Update search query on input change.
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
                      _searchQuery = ''; // Clear search query.
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

  // Builds filter chips for filtering shifts.
  Widget _buildFilterChips() {
    final filters = ['All', 'Assigned', 'Complete', 'Requests', 'Today', 'This Week'];

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
                  _selectedFilter = filter; // Update selected filter.
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

  // Builds a stats card showing counts of caregivers and pending assignments.
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
      child: Row(
        children: [
          // Display available caregivers count.
          Expanded(
            child: _buildStatItem(
              'Available\nCaregivers',
              _availableCaregivers.length.toString(),
              Icons.people,
            ),
          ),
          // Divider between stats.
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          // Display pending assignments count.
          Expanded(
            child: _buildStatItem(
              'Pending\nAssignments',
              _allShifts.where((shift) => shift.caregiverId == null).length.toString(),
              Icons.assignment_late,
            ),
          ),
        ],
      ),
    );
  }

  // Builds an individual stat item for the stats card.
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

  // Builds the main UI for the shift assignment screen.
  @override
  Widget build(BuildContext context) {
    // Define time boundaries for filtering shifts by day or week.
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Filter shifts based on search query and selected filter.
    final filteredShifts = _allShifts.where((shift) {
      final matchesSearch = _searchQuery.isEmpty ||
          shift.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Requests' && shift.status == 'request') ||
          (_selectedFilter == 'Assigned' && shift.status == 'pending') ||
          (_selectedFilter == 'Today' &&
              shift.startTime.isAfter(startOfDay) &&
              shift.startTime.isBefore(startOfDay.add(const Duration(days: 1)))) ||
          (_selectedFilter == 'This Week' &&
              shift.startTime.isAfter(startOfWeek) &&
              shift.startTime.isBefore(endOfWeek)) ||
          (_selectedFilter == 'Complete' && shift.status == 'complete');

      return matchesSearch && matchesFilter;
    }).toList();

    return ModernScreenLayout(
      title: 'Shift Assignment',
      showBackButton: true,
      // Navigate to admin dashboard when back button is pressed.
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      // Floating action buttons for refreshing data and adding a shift.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'refreshButton',
            onPressed: () => _refreshData(context),
            backgroundColor: AppTheme.neutral600,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'addShiftButton',
            onPressed: _showCreateShiftDialog,
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats card showing caregiver and shift counts.
                _buildStatsCard(),
                // Search bar for filtering.
                _buildSearchBar(),
                // Filter chips for shift categories.
                _buildFilterChips(),
                const SizedBox(height: 24),
                // Section for displaying available caregivers.
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      // Display count of available caregivers.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.successGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${_availableCaregivers.length}',
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
                // Display caregivers or empty state.
                _availableCaregivers.isEmpty
                    ? Container(
                        height: 120,
                        child: _buildEmptyState(
                            'No caregivers available', Icons.person_off),
                      )
                    : Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _availableCaregivers.length,
                          itemBuilder: (context, index) {
                            final caregiver = _availableCaregivers[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.neutral600.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor:
                                          AppTheme.primaryBlue.withOpacity(0.1),
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
                                        borderRadius: BorderRadius.circular(12),
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
                // Section for unassigned shifts.
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
                        'Kindly assign caregivers to shifts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      // Display count of filtered shifts.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.accentOrange.withOpacity(0.3)),
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
                // Display filtered shifts or empty state.
                filteredShifts.isEmpty
                    ? Container(
                        height: 200,
                        child: _buildEmptyState(
                          _searchQuery.isNotEmpty
                              ? 'No shifts match your search'
                              : 'No shifts match your filter',
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
                                  color: AppTheme.accentOrange.withOpacity(0.1),
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
                                          ? AppTheme.errorRed.withOpacity(0.1)
                                          : AppTheme.errorRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
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
          ),
        ),
      ),
    );
  }
}