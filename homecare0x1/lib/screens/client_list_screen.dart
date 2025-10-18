// lib/screens/client_list_screen.dart
// Updated screen for displaying and managing clients with Firebase integration.
// Features:
// - Fetches clients from Firestore backend
// - Search functionality for filtering clients
// - Popup dialog showing client details and shift history
// - Refresh capability to reload data
// - Modern UI with animations

import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/client_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:intl/intl.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen>
    with SingleTickerProviderStateMixin {
  // Controllers and animation setup
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Service instances for Firebase operations
  final FirebaseClientService _clientService = FirebaseClientService.instance;
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;

  // State management
  bool _isLoading = false;
  String _searchQuery = '';
  List<Client> _clients = [];
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();

    // Setup search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterClients();
      });
    });

    // Setup animations for smooth screen transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    // Load clients from Firebase on screen initialization
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Loads all clients from Firebase backend
  /// Sets loading state and updates UI on completion
  Future<void> _loadClients() async {
    setState(() => _isLoading = true);

    try {
      final clients = await _clientService.getAllClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load clients: $e');
    }
  }

  /// Refreshes the client list from Firebase
  /// Shows success message on completion
  Future<void> _refreshClients() async {
    await _loadClients();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Client list refreshed!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Filters clients based on search query
  /// Searches through name, email, and address fields
  void _filterClients() {
    if (_searchQuery.isEmpty) {
      _filteredClients = _clients;
    } else {
      _filteredClients = _clients.where((client) {
        return client.name.toLowerCase().contains(_searchQuery) ||
            client.email.toLowerCase().contains(_searchQuery) ||
            client.address.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  /// Shows a dialog with detailed client information and shift history
  /// Fetches shifts from Firebase and displays them chronologically
  Future<void> _showClientDetails(Client client) async {
    // Show loading dialog while fetching shifts
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch client's shift history from Firebase
      final shifts = await _shiftService.getShiftsForClient(client.id);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show client details dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildClientDetailsDialog(client, shifts),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackBar('Failed to load client details: $e');
    }
  }

  /// Builds the client details dialog UI
  /// Displays client information and shift history in a scrollable view
  Widget _buildClientDetailsDialog(Client client, List<Shift> shifts) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog header with client name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Client Details',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Information Section
                    _buildSectionTitle('Client Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: client.email,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: client.address,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.medical_services,
                      label: 'Care Plan',
                      value: client.carePlan,
                    ),

                    const SizedBox(height: 32),

                    // Shift History Section
                    _buildSectionTitle('Shift History'),
                    const SizedBox(height: 16),

                    // Display shifts or empty state
                    shifts.isEmpty
                        ? _buildEmptyShiftsState()
                        : _buildShiftsList(shifts),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.neutral600,
      ),
    );
  }

  /// Builds an information card displaying a labeled value
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of shifts for the client
  Widget _buildShiftsList(List<Shift> shifts) {
    return Column(
      children: shifts.map((shift) => _buildShiftCard(shift)).toList(),
    );
  }

  /// Builds a card displaying individual shift information
  Widget _buildShiftCard(Shift shift) {
    // Format dates and times for display
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Calculate shift duration
    final duration = shift.endTime.difference(shift.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationText = '${hours}h ${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral100),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift date and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(shift.startTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutral600,
                    ),
                  ),
                ],
              ),
              _buildStatusChip(shift.status),
            ],
          ),
          const SizedBox(height: 12),

          // Shift time range and duration
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppTheme.neutral600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${timeFormat.format(shift.startTime)} - ${timeFormat.format(shift.endTime)}',
                  style: TextStyle(color: AppTheme.neutral600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  durationText,
                  style: TextStyle(
                    color: AppTheme.neutral600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Caregiver name if assigned
          if (shift.caregiverName != null &&
              shift.caregiverName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Caregiver: ${shift.caregiverName}',
                    style: TextStyle(
                      color: AppTheme.neutral600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (shift.caregiverId != null &&
              shift.caregiverId!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: AppTheme.neutral600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Caregiver ID: ${shift.caregiverId}',
                    style: TextStyle(
                      color: AppTheme.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Broadcast status indicator
          if (shift.broadcast == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.wifi_tethering,
                    size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Broadcasted to caregivers',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],

          // Location information if available
          if (shift.location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.errorRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: ${shift.location!.latitude.toStringAsFixed(4)}, ${shift.location!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: AppTheme.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Admin notes if present
          if (shift.adminNotes != null && shift.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neutral100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: AppTheme.neutral600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Notes:',
                          style: TextStyle(
                            color: AppTheme.neutral600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shift.adminNotes!,
                          style: TextStyle(
                            color: AppTheme.neutral600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a status chip with color coding based on shift status
  /// Supports: pending, in_session, completed, cancelled, request
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = AppTheme.successGreen.withOpacity(0.2);
        textColor = AppTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case 'in_session':
        backgroundColor = AppTheme.primaryBlue.withOpacity(0.2);
        textColor = AppTheme.primaryBlue;
        icon = Icons.play_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'request':
        backgroundColor = Colors.purple.withOpacity(0.2);
        textColor = Colors.purple;
        icon = Icons.request_page;
        break;
      case 'cancelled':
        backgroundColor = AppTheme.errorRed.withOpacity(0.2);
        textColor = AppTheme.errorRed;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = AppTheme.neutral100;
        textColor = AppTheme.neutral600;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an empty state widget when no shifts are found
  Widget _buildEmptyShiftsState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 60, color: AppTheme.neutral600),
          const SizedBox(height: 16),
          Text(
            'No shifts found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This client has no shift history yet.',
            style: TextStyle(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }

  /// Shows an error message as a snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Client List',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Clients',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'View and manage your assigned clients',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_clients.length} total clients',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search clients by name, email, or address...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.neutral600),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppTheme.neutral600),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                  ),
                ),
                const SizedBox(height: 24),

                // Refresh Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ModernButton(
                    text: 'Refresh',
                    icon: Icons.refresh,
                    isLoading: _isLoading,
                    onPressed: _refreshClients,
                  ),
                ),
                const SizedBox(height: 16),

                // Loading indicator or Client List
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _filteredClients.isEmpty
                        ? _buildEmptyState()
                        : _buildClientList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state when no clients match the search
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.people_outline, size: 80, color: AppTheme.neutral600),
          const SizedBox(height: 16),
          Text(
            'No Clients Found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'No clients in the system yet.'
                : 'Try adjusting your search or refresh the list.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral600,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of client cards
  Widget _buildClientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: 4,
            shadowColor: AppTheme.neutral100.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                ),
              ),
              title: Text(
                client.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral600,
                    ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    client.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutral600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.address,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutral600.withOpacity(0.7),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClientDetails(client),
            ),
          ),
        );
      },
    );
  }
}
