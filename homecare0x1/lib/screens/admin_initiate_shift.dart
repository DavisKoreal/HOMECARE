import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/location.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';

/// Main screen for administrators to initiate and create new shifts
/// Allows searching and selecting clients and caregivers, setting shift times,
/// and broadcasting shifts to available caregivers
class AdminInitiateShift extends StatefulWidget {
  const AdminInitiateShift({super.key});

  @override
  State<AdminInitiateShift> createState() => _AdminInitiateShiftState();
}

class _AdminInitiateShiftState extends State<AdminInitiateShift>
    with SingleTickerProviderStateMixin {
  // ==================== Controllers ====================
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _caregiverSearchController = TextEditingController();
  final TextEditingController _adminNotesController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==================== State Variables ====================
  bool _isLoading = false;
  String _clientSearchQuery = '';
  String _caregiverSearchQuery = '';
  
  // Selected client data
  String? _selectedClientId;
  String? _selectedClientName;
  
  // Selected caregiver data
  String? _selectedCaregiverId;
  String? _selectedCaregiverName;
  
  // Shift timing
  DateTime? _startTime;
  DateTime? _endTime;
  
  // Broadcast flag - determines if shift is sent to all available caregivers
  bool _broadcast = false;

  // Progress tracking
  int _currentStep = 0;
  final int _totalSteps = 4; // Client, Caregiver, Schedule, Notes

  // Data lists
  List<Client> _clients = [];
  List<CaregiverProfile> _caregivers = [];

  // ==================== Lifecycle Methods ====================
  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupAnimations();
    _setupSearchListeners();
  }

  @override
  void dispose() {
    _clientSearchController.dispose();
    _caregiverSearchController.dispose();
    _adminNotesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== Initialization Methods ====================
  
  /// Initialize screen by fetching required data
  void _initializeScreen() {
    _fetchClients();
    _fetchCaregivers();
  }

  /// Setup entrance animations for smooth UI transitions
  void _setupAnimations() {
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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  /// Setup listeners for search field changes
  void _setupSearchListeners() {
    _clientSearchController.addListener(() {
      setState(() {
        _clientSearchQuery = _clientSearchController.text.toLowerCase();
      });
    });

    _caregiverSearchController.addListener(() {
      setState(() {
        _caregiverSearchQuery = _caregiverSearchController.text.toLowerCase();
      });
    });
  }

  // ==================== Data Fetching Methods ====================
  
  /// Fetch all clients from Firebase
  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      _clients = await FirebaseShiftService.instance.getAllClients();
    } catch (e) {
      _showErrorMessage('Error fetching clients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch all caregiver profiles from Firebase
  Future<void> _fetchCaregivers() async {
    setState(() => _isLoading = true);
    try {
      _caregivers = await FirebaseCaregiverService.instance.getAllCaregiverProfiles();
    } catch (e) {
      _showErrorMessage('Error fetching caregivers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== Date/Time Selection Methods ====================
  
  /// Show date and time picker dialogs for shift scheduling
  /// [isStart] determines if we're setting start or end time
  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    // First, select the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    // Then, select the time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // Combine date and time into a single DateTime object
    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selectedDateTime;
      } else {
        _endTime = selectedDateTime;
      }
    });
  }

  // ==================== Step Navigation ====================
  
  /// Move to next step with validation
  void _nextStep() {
    if (_currentStep == 0) {
      // Validate client selection
      if (_selectedClientId == null || _selectedClientName == null) {
        _showErrorMessage('Please select a client');
        return;
      }
    } else if (_currentStep == 1) {
      // Validate caregiver selection (only if not broadcasting)
      if (!_broadcast && (_selectedCaregiverId == null || _selectedCaregiverName == null)) {
        _showErrorMessage('Please select a caregiver or enable broadcast mode');
        return;
      }
    } else if (_currentStep == 2) {
      // Validate date/time
      if (_startTime == null || _endTime == null) {
        _showErrorMessage('Please select both start and end times');
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        _showErrorMessage('End time must be after start time');
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  /// Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // ==================== Form Validation & Submission ====================
  
  /// Validate form inputs before submission
  bool _validateForm() {
    if (_selectedClientId == null || _selectedClientName == null) {
      _showErrorMessage('Please select a client');
      return false;
    }

    if (_startTime == null || _endTime == null) {
      _showErrorMessage('Please select both start and end times');
      return false;
    }

    if (_endTime!.isBefore(_startTime!)) {
      _showErrorMessage('End time must be after start time');
      return false;
    }

    // If not broadcasting, caregiver must be selected
    if (!_broadcast && (_selectedCaregiverId == null || _selectedCaregiverName == null)) {
      _showErrorMessage('Please select a caregiver or enable broadcast mode');
      return false;
    }

    return true;
  }

  /// Submit the shift creation request to Firebase
  Future<void> _submitShift() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final result = await FirebaseShiftService.instance.addShift(
        clientId: _selectedClientId!,
        clientName: _selectedClientName!,
        startTime: _startTime!,
        endTime: _endTime!,
        context: context,
        caregiverId: _selectedCaregiverId,
        caregiverName: _selectedCaregiverName,
        broadcast: _broadcast,
        adminNotes: _adminNotesController.text.trim().isNotEmpty 
            ? _adminNotesController.text.trim() 
            : null,
      );

      if (result == 'success') {
        _showSuccessMessage('Shift created successfully!');
        Navigator.pushReplacementNamed(context, Routes.adminDashboard);
      } else {
        _showErrorMessage('Failed to create shift');
      }
    } catch (e) {
      _showErrorMessage('Error creating shift: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== Client Selection Methods ====================
  
  /// Handle client selection from the list
  void _selectClient(Client client) {
    setState(() {
      _selectedClientId = client.id;
      _selectedClientName = client.name;
      _clientSearchController.text = client.name;
    });
  }

  /// Clear client selection
  void _clearClientSelection() {
    setState(() {
      _selectedClientId = null;
      _selectedClientName = null;
      _clientSearchController.clear();
    });
  }

  // ==================== Caregiver Selection Methods ====================
  
  /// Handle caregiver selection from the list
  void _selectCaregiver(CaregiverProfile caregiver) {
    setState(() {
      _selectedCaregiverId = caregiver.id;
      _selectedCaregiverName = caregiver.name;
      _caregiverSearchController.text = caregiver.name;
    });
  }

  /// Clear caregiver selection
  void _clearCaregiverSelection() {
    setState(() {
      _selectedCaregiverId = null;
      _selectedCaregiverName = null;
      _caregiverSearchController.clear();
    });
  }

  // ==================== Filtered Lists (Computed Properties) ====================
  
  /// Get filtered client list based on search query
  List<Client> get _filteredClients {
    if (_clientSearchQuery.isEmpty) return _clients;
    return _clients.where((client) {
      return client.name.toLowerCase().contains(_clientSearchQuery) ||
          client.id.toLowerCase().contains(_clientSearchQuery);
    }).toList();
  }

  /// Get filtered caregiver list based on search query
  List<CaregiverProfile> get _filteredCaregivers {
    if (_caregiverSearchQuery.isEmpty) return _caregivers;
    return _caregivers.where((caregiver) {
      return caregiver.name.toLowerCase().contains(_caregiverSearchQuery) ||
          caregiver.id.toLowerCase().contains(_caregiverSearchQuery);
    }).toList();
  }

  // ==================== UI Helper Methods ====================
  
  /// Show error message via SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show success message via SnackBar
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== Build Methods ====================
  
  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Initiate Shift',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderBanner(),
                      const SizedBox(height: 24),
                      _buildStepContent(),
                      const SizedBox(height: 24),
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _totalSteps;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral600,
                ),
              ),
              Text(
                _getStepTitle(_currentStep),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.neutral100,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Get step title
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Client';
      case 1:
        return 'Select Caregiver';
      case 2:
        return 'Set Schedule';
      case 3:
        return 'Add Notes';
      default:
        return '';
    }
  }

  /// Build step content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildClientSection();
      case 1:
        return _buildCaregiverSection();
      case 2:
        return _buildScheduleSection();
      case 3:
        return _buildAdminNotesSection();
      default:
        return const SizedBox();
    }
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ModernButton(
              text: 'Previous',
              icon: Icons.arrow_back,
              onPressed: _previousStep,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ModernButton(
            text: _currentStep == _totalSteps - 1 ? 'Create Shift' : 'Next',
            icon: _currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward,
            isLoading: _isLoading,
            onPressed: _currentStep == _totalSteps - 1 ? _submitShift : _nextStep,
          ),
        ),
      ],
    );
  }

  /// Build the header banner with gradient background
  Widget _buildHeaderBanner() {
    return Container(
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
            'Create a New Shift',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepDescription(_currentStep),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Get step description
  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Choose the client who needs care';
      case 1:
        return 'Assign a caregiver or broadcast to all';
      case 2:
        return 'Set the shift start and end times';
      case 3:
        return 'Add any important notes or instructions';
      default:
        return 'Complete the shift creation process';
    }
  }

  /// Build the client search and selection section
  Widget _buildClientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Client',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 12),
        _buildSearchField(
          controller: _clientSearchController,
          hintText: 'Search clients by name or ID...',
          onClear: _clearClientSelection,
          hasSelection: _selectedClientId != null,
        ),
        const SizedBox(height: 16),
        _buildClientList(),
      ],
    );
  }

  /// Build the caregiver search and selection section
  Widget _buildCaregiverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Caregiver',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral600,
                  ),
            ),
            const SizedBox(width: 8),
            if (_broadcast)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBroadcastToggle(),
        const SizedBox(height: 16),
        _buildSearchField(
          controller: _caregiverSearchController,
          hintText: 'Search caregivers by name or ID...',
          onClear: _clearCaregiverSelection,
          hasSelection: _selectedCaregiverId != null,
        ),
        const SizedBox(height: 16),
        _buildCaregiverList(),
      ],
    );
  }

  /// Build schedule section
  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Schedule',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                label: _startTime == null
                    ? 'Select Start'
                    : DateFormat('MMM d, yyyy\nh:mm a').format(_startTime!),
                icon: Icons.calendar_today,
                onPressed: () => _selectDateTime(context, true),
                isSelected: _startTime != null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeButton(
                label: _endTime == null
                    ? 'Select End'
                    : DateFormat('MMM d, yyyy\nh:mm a').format(_endTime!),
                icon: Icons.event,
                onPressed: () => _selectDateTime(context, false),
                isSelected: _endTime != null,
              ),
            ),
          ],
        ),
        if (_startTime != null && _endTime != null) ...[
          const SizedBox(height: 16),
          _buildShiftSummaryCard(),
        ],
      ],
    );
  }

  /// Build shift summary card
  Widget _buildShiftSummaryCard() {
    final duration = _endTime!.difference(_startTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.primaryBlue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Shift Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$hours hours and $minutes minutes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build admin notes section
  Widget _buildAdminNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Notes (Optional)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add any important instructions, special requirements, or notes for the caregiver.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.neutral600,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _adminNotesController,
          maxLines: 8,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Enter detailed notes here...\n\nExample: Client prefers morning medication at 9 AM. Ensure to check blood pressure before administering. Family will be visiting at 2 PM.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.neutral600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.neutral600.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.neutral100,
            counterText: '${_adminNotesController.text.length}/1000',
          ),
        ),
        const SizedBox(height: 16),
        _buildShiftReviewCard(),
      ],
    );
  }

  /// Build shift review card
  Widget _buildShiftReviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Shift Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReviewRow('Client', _selectedClientName ?? 'Not selected', Icons.person),
            const Divider(height: 24),
            _buildReviewRow(
              'Caregiver', 
              _broadcast 
                  ? 'Broadcast to all' 
                  : (_selectedCaregiverName ?? 'Not selected'),
              Icons.medical_services,
            ),
            const Divider(height: 24),
            _buildReviewRow(
              'Start Time',
              _startTime != null 
                  ? DateFormat('MMM d, yyyy - h:mm a').format(_startTime!)
                  : 'Not set',
              Icons.calendar_today,
            ),
            const Divider(height: 24),
            _buildReviewRow(
              'End Time',
              _endTime != null 
                  ? DateFormat('MMM d, yyyy - h:mm a').format(_endTime!)
                  : 'Not set',
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  /// Build review row
  Widget _buildReviewRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.neutral600.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build reusable search field widget
  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onClear,
    required bool hasSelection,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: AppTheme.neutral600),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppTheme.neutral600),
                onPressed: onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hasSelection
              ? BorderSide(color: AppTheme.successGreen, width: 2)
              : BorderSide(color: AppTheme.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hasSelection
              ? BorderSide(color: AppTheme.successGreen, width: 2)
              : BorderSide(color: AppTheme.neutral600.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: AppTheme.neutral100,
      ),
    );
  }

  /// Build the client list view
  Widget _buildClientList() {
    if (_filteredClients.isEmpty) {
      return _buildEmptyState('No Clients Found');
    }

    return SizedBox(
      height: _calculateListHeight(_filteredClients.length),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          final client = _filteredClients[index];
          final isSelected = _selectedClientId == client.id;
          return _buildPersonCard(
            name: client.name,
            id: client.id,
            isSelected: isSelected,
            onTap: () => _selectClient(client),
          );
        },
      ),
    );
  }

  /// Build the caregiver list view
  Widget _buildCaregiverList() {
    if (_filteredCaregivers.isEmpty) {
      return _buildEmptyState('No Caregivers Found');
    }

    return SizedBox(
      height: _calculateListHeight(_filteredCaregivers.length),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredCaregivers.length,
        itemBuilder: (context, index) {
          final caregiver = _filteredCaregivers[index];
          final isSelected = _selectedCaregiverId == caregiver.id;
          return _buildPersonCard(
            name: caregiver.name,
            id: caregiver.id,
            isSelected: isSelected,
            onTap: () => _selectCaregiver(caregiver),
          );
        },
      ),
    );
  }

  /// Build reusable person card (for both clients and caregivers)
  Widget _buildPersonCard({
    required String name,
    required String id,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.successGreen, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isSelected ? AppTheme.successGreen.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? AppTheme.successGreen.withOpacity(0.15)
              : AppTheme.primaryBlue.withOpacity(0.15),
          child: Icon(
            isSelected ? Icons.check : Icons.person,
            color: isSelected ? AppTheme.successGreen : AppTheme.primaryBlue,
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral600,
              ),
        ),
        subtitle: Text(
          'ID: $id',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutral600,
              ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.successGreen)
            : null,
        onTap: onTap,
      ),
    );
  }

  /// Build empty state widget for lists
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.people_outline, size: 80, color: AppTheme.neutral600),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Calculate appropriate height for lists based on item count
  double _calculateListHeight(int itemCount) {
    const double itemHeight = 80.0;
    const int maxVisibleItems = 3;
    return itemCount < maxVisibleItems
        ? itemCount * itemHeight
        : maxVisibleItems * itemHeight;
  }

  /// Build individual date/time button
  Widget _buildDateTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return ModernButton(
      text: label,
      icon: icon,
      onPressed: onPressed,
    );
  }

  /// Build broadcast toggle switch
  Widget _buildBroadcastToggle() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text(
          'Broadcast Shift',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _broadcast
              ? 'Shift will be sent to all available caregivers'
              : 'Shift will be assigned to selected caregiver only',
          style: TextStyle(fontSize: 12, color: AppTheme.neutral600),
        ),
        value: _broadcast,
        onChanged: (value) {
          setState(() {
            _broadcast = value;
            // Clear caregiver selection if broadcasting
            if (value) {
              _clearCaregiverSelection();
              _showSuccessMessage('Broadcast mode enabled. Caregiver selection cleared.');
            }
          });
        },
        activeColor: AppTheme.successGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}