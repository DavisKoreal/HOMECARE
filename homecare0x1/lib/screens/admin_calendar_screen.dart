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

// Enum for calendar view modes
enum CalendarView { month, week }

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
  // State variable for calendar view mode
  CalendarView _calendarView = CalendarView.month;

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
        // Sort shifts for each day by start time
        for (var entry in _events.entries) {
          entry.value.sort((a, b) => a.startTime.compareTo(b.startTime));
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

  // Builds the toggle for switching between month and week views
 // Builds the toggle for switching between month and week views
Widget _buildViewToggle() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ModernButton(
        text: 'Month',
        icon: Icons.calendar_month, // Added required icon parameter
        onPressed: () {
          setState(() {
            _calendarView = CalendarView.month;
          });
        },
      ),
      const SizedBox(width: 16),
      ModernButton(
        text: 'Week',
        icon: Icons.view_week, // Added required icon parameter
        onPressed: () {
          setState(() {
            _calendarView = CalendarView.week;
          });
        },
      ),
    ],
  );
}

  // Builds the weekly schedule list view
  Widget _buildWeeklySchedule() {
    // Calculate the start of the week (assuming Monday as first day)
    int daysToSubtract = _focusedDay.weekday - DateTime.monday;
    DateTime monday = _focusedDay.subtract(Duration(days: daysToSubtract));
    DateTime sunday = monday.add(const Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation for previous/next week
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                });
              },
            ),
            Text(
              '${DateFormat('MMMM d').format(monday)} - ${DateFormat('MMMM d').format(sunday)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Generate list for each day
        ...List.generate(7, (index) {
          DateTime day = monday.add(Duration(days: index));
          List<Shift> shifts = _getEventsForDay(day);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(day),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (shifts.isEmpty)
                const Text('No shifts scheduled'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shifts.length,
                itemBuilder: (context, i) {
                  Shift shift = shifts[i];
                  return ListTile(
                    title: Text(shift.clientName),
                    subtitle: Text(
                      '${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}',
                    ),
                    trailing: Text(shift.caregiverName ?? 'Unassigned'),
                    // Optional: Add onTap to navigate to shift details if needed
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
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
    var tableCalendar = TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      calendarFormat: CalendarFormat.month, // Fixed to month when in month view
      // Handle day selection and navigate to shift list.
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(
            context,
            Routes.shiftList,
            arguments: selectedDay,
          );
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
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
    );
    
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
                        _buildViewToggle(),
                        const SizedBox(height: 16),
                        if (_calendarView == CalendarView.month)
                          tableCalendar
                        else
                          _buildWeeklySchedule(),
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