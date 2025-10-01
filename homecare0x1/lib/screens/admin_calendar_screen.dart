import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:homecare0x1/actions/overlay.dart';// Import the utility class for overlay notifications.

// Admin calendar screen widget to display and manage shifts.
class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => AdminCalendarScreenState();
}

// State class for AdminCalendarScreen, handling the calendar and shift management.
class AdminCalendarScreenState extends State<AdminCalendarScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for fade-in effect of the calendar.
  late AnimationController _animationController;
  // Animation for smooth fade-in transition.
  late Animation<double> _fadeAnimation;
  // The currently focused day in the calendar.
  late DateTime _focusedDay;
  // The selected day, nullable as no day may be selected initially.
  late DateTime? _selectedDay;
  // Map to store shifts by date for quick lookup.
  final Map<DateTime, List<Shift>> _events = {};
  // Flag to indicate if data is being loaded.
  bool _isLoading = true;
  // Error message to display if shift loading fails, nullable.
  String? _errorMessage;
  // Instance of OverlayUtils for showing notifications.
  late OverlayUtils _overlayUtils;

  @override
  void initState() {
    super.initState();
    // Initialize the screen's state.
    _initialize();
    // Create an instance of OverlayUtils for notifications.
    _overlayUtils = OverlayUtils();
  }

  // Initializes state variables and starts the animation.
  void _initialize() {
    // Log initialization for debugging.
    print('Admin Calendar Screen Initialized');
    // Set the focused and selected day to the current date.
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    // Initialize animation controller with an 800ms duration.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Create a fade animation from 0.0 (invisible) to 1.0 (fully visible).
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Start the fade-in animation.
    _animationController.forward();
    // Load shift events from the provider.
    _loadEvents();
  }

  // Loads shift events from the ShiftAssignmentProvider and updates the UI.
  Future<void> _loadEvents() async {
    // Create a random instance for selecting random messages.
    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    // Show a loading message in an overlay after the frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // List of possible loading messages for variety.
      List<String> messages = [
        'Loading calendar...',
        'Fetching shifts...',
        'Please wait while I load the calendar...',
        'Retrieving shifts for the selected day...',
        'Hang on, loading your calendar...',
        'Preparing your calendar view...',
      ];
      _overlayUtils.showOverlay(context, messages[random.nextInt(messages.length)]);
    });

    try {
      // Access the ShiftAssignmentProvider to fetch shifts.
      final provider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
      // Create another random instance (redundant, consider reusing the previous one).
      Random random = Random(DateTime.now().millisecondsSinceEpoch);
      // Fetch shifts from the provider.
      await provider.fetchShifts();
      setState(() {
        // Clear existing events to avoid duplicates.
        _events.clear();
        // Group shifts by date for calendar display.
        for (final shift in provider.allShifts) {
          final day = DateTime(shift.startTime.year, shift.startTime.month, shift.startTime.day);
          _events[day] ??= [];
          _events[day]!.add(shift);
        }
        // Set loading flag to false as data is loaded.
        _isLoading = false;
      });

      // Show a success message after loading shifts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // List of success messages for variety.
        List<String> successMessages = [
          'Your calendar has been loaded successfully!',
          'Shifts retrieved successfully! Click date to view details.',
          'All shifts are up-to-date!',
          'Calendar is ready for use! Click on a date to see shifts.',
          'Shifts loaded successfully! View them by clicking a date.',
          'Your calendar is now updated! Tap on a date',
        ];
        // Display a message indicating the number of shifts loaded or no shifts.
        final message = provider.allShifts.isEmpty
            ? 'No shifts available'
            : '${successMessages[random.nextInt(successMessages.length)]} Loaded ${provider.allShifts.length} shifts';
        _overlayUtils.showOverlay(context, message);
      });
    } catch (e) {
      // Handle errors during shift loading.
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load shifts: $e';
      });
      // Show error message in an overlay.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayUtils.showOverlay(context, _errorMessage!, isError: true);
      });
    }
  }

  // Retrieves shifts for a given day from the events map.
  List<Shift> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }


  // Shows a dialog to edit an existing shift.
  Future<void> _showEditShiftDialog(Shift shift) async {
    // Initialize variables with the shift's current values.
    DateTime? startTime = shift.startTime;
    DateTime? endTime = shift.endTime;
    String? selectedCaregiverId = shift.caregiverId;
    String? selectedCaregiverName = shift.caregiverName;

    // Display a dialog for editing the shift.
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Apply rounded corners to the dialog.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Shift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the client name (non-editable).
              Text('Client: ${shift.clientName}'),
              const SizedBox(height: 16),
              // Dropdown to select a caregiver.
              Consumer<ShiftAssignmentProvider>(
                builder: (context, provider, child) {
                  final caregivers = provider.availableCaregivers;
                  return DropdownButtonFormField<String>(
                    value: selectedCaregiverId,
                    decoration: const InputDecoration(
                      labelText: 'Caregiver (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      // Option for no caregiver.
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('None'),
                      ),
                      // List all available caregivers.
                      ...caregivers.map((caregiver) => DropdownMenuItem<String>(
                            value: caregiver.id,
                            child: Text(caregiver.name),
                          )),
                    ],
                    onChanged: (value) {
                      // Update caregiver ID and name when selection changes.
                      selectedCaregiverId = value;
                      selectedCaregiverName = value != null
                          ? caregivers.firstWhere((c) => c.id == value).name
                          : null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Button to select start time.
              ModernButton(
                text: 'Select Start Time',
                icon: Icons.access_time,
                onPressed: () async {
                  // Show time picker and update start time if selected.
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(shift.startTime),
                  );
                  if (time != null) {
                    setState(() {
                      startTime = DateTime(
                        shift.startTime.year,
                        shift.startTime.month,
                        shift.startTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Button to select end time.
              ModernButton(
                text: 'Select End Time',
                icon: Icons.access_time,
                onPressed: () async {
                  // Show time picker and update end time if selected.
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(shift.endTime),
                  );
                  if (time != null) {
                    setState(() {
                      endTime = DateTime(
                        shift.endTime.year,
                        shift.endTime.month,
                        shift.endTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          // Cancel button to dismiss the dialog.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Button to save changes to the shift.
          ModernButton(
            text: 'Save Changes',
            icon: Icons.save,
            onPressed: () async {
              // Validate inputs and update the shift.
              if (startTime != null && endTime != null) {
                try {
                  // Update the shift using the provider.
                  await Provider.of<ShiftAssignmentProvider>(context, listen: false).updateShift(
                    shiftId: shift.id,
                    startTime: startTime!,
                    endTime: endTime!,
                    context: context,
                    caregiverId: selectedCaregiverId,
                    caregiverName: selectedCaregiverName,
                  );
                  // Close the dialog.
                  Navigator.pop(context);
                  // Reload events to reflect the updated shift.
                  await _loadEvents();
                  // Show success notification.
                  _overlayUtils.showOverlay(context, 'Shift updated successfully');
                } catch (e) {
                  // Show error notification if updating fails.
                  _overlayUtils.showOverlay(context, 'Error: $e', isError: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Cleans up resources when the widget is disposed.
  @override
  void dispose() {
    // Clean up the overlay utility.
    _overlayUtils.dispose();
    // Dispose of the animation controller.
    _animationController.dispose();
    super.dispose();
  }

  // Builds the UI for the admin calendar screen.
  @override
  Widget build(BuildContext context) {
    // Access the UserProvider for user-related data.
    final userProvider = Provider.of<UserProvider>(context);
    return ModernScreenLayout(
      title: 'Admin Calendar',
      showBackButton: true,
      // Navigate back when the back button is pressed.
      onBackPressed: () => Navigator.pop(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator.
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!)) // Show error message if loading fails.
              : FadeTransition(
                  // Apply fade animation to the calendar content.
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar widget to display shifts.
                        TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getEventsForDay,
                          calendarFormat: CalendarFormat.month,
                          // Handle day selection and navigate to shift list.
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            Navigator.pushNamed(
                              context,
                              Routes.shiftList,
                              arguments: selectedDay,
                            );
                          },
                          // Customize calendar appearance.
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: AppTheme.accentOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Button to open the add shift dialog.
                        // ModernButton(
                        //   text: 'Add New Shift',
                        //   icon: Icons.add,
                        //   onPressed: _showAddShiftDialog,
                        // ),
                      ],
                    ),
                  ),
                ),
    );
  }
}