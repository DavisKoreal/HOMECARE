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

class AdminInitiateShift extends StatefulWidget {
  const AdminInitiateShift({super.key});

  @override
  State<AdminInitiateShift> createState() => _AdminInitiateShiftState();
}

class _AdminInitiateShiftState extends State<AdminInitiateShift> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _caregiverSearchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedClientId;
  String? _selectedCaregiverId;
  String? _selectedCaregiverName;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _broadcast = false;

  List<Client> _clients = [];
  List<CaregiverProfile> _caregivers = [];

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _fetchCaregivers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _caregiverSearchController.addListener(() {
      setState(() {
        _searchQuery = _caregiverSearchController.text.toLowerCase();
      });
    });

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _caregiverSearchController.dispose();
    _clientNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      _clients = await FirebaseShiftService.instance.getAllClients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching clients: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCaregivers() async {
    setState(() => _isLoading = true);
    try {
      _caregivers = await FirebaseCaregiverService.instance.getAllCaregiverProfiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching caregivers: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
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
    }
  }

  Future<void> _submitShift() async {
    if (_selectedClientId == null || _clientNameController.text.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await FirebaseShiftService.instance.addShift(
      clientId: _selectedClientId!,
      clientName: _clientNameController.text,
      startTime: _startTime!,
      endTime: _endTime!,
      context: context,
      caregiverId: _selectedCaregiverId,
      caregiverName: _selectedCaregiverName,
      broadcast: _broadcast,
    );

    setState(() => _isLoading = false);
    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Shift created successfully!', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushReplacementNamed(context, Routes.adminDashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create shift', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    return _clients
        .where((client) =>
            client.name.toLowerCase().contains(_searchQuery) ||
            client.id.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<CaregiverProfile> get _filteredCaregivers {
    if (_searchQuery.isEmpty) return _caregivers;
    return _caregivers
        .where((caregiver) =>
            caregiver.name.toLowerCase().contains(_searchQuery) ||
            caregiver.id.toLowerCase().contains(_searchQuery)) 
        .toList();
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
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
                        'Create a New Shift',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assign a shift to a client and caregiver',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Client Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search clients by name or ID...',
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
                const SizedBox(height: 16),

                // Client List
                _filteredClients.isEmpty
                    ? Center(
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
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                                  child: Icon(Icons.person, color: AppTheme.primaryBlue),
                                ),
                                title: Text(
                                  client.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.neutral600,
                                      ),
                                ),
                                subtitle: Text(
                                  'ID: ${client.id}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.neutral600,
                                      ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedClientId = client.id;
                                    _clientNameController.text = client.name;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 24),

                // Client Name Field
                TextField(
                  controller: _clientNameController,
                  decoration: InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                  ),
                ),
                const SizedBox(height: 16),

                // Caregiver Search
                TextField(
                  controller: _caregiverSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search caregivers by name or ID...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.neutral600),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppTheme.neutral600),
                            onPressed: () {
                              _caregiverSearchController.clear();
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
                const SizedBox(height: 16),

                // Caregiver List
                _filteredCaregivers.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.people_outline, size: 80, color: AppTheme.neutral600),
                            const SizedBox(height: 16),
                            Text(
                              'No Caregivers Found',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral600,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredCaregivers.length,
                          itemBuilder: (context, index) {
                            final caregiver = _filteredCaregivers[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                                  child: Icon(Icons.person, color: AppTheme.primaryBlue),
                                ),
                                title: Text(
                                  caregiver.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.neutral600,
                                      ),
                                ),
                                subtitle: Text(
                                  'ID: ${caregiver.id}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.neutral600,
                                      ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCaregiverId = caregiver.id;
                                    _selectedCaregiverName = caregiver.name;
                                    // set controller text to caregiver name
                                    _caregiverSearchController.text = caregiver.name;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 24),

                // Date and Time Pickers
              Wrap(
                spacing: 16, // Horizontal spacing between buttons
                runSpacing: 8, // Vertical spacing between lines
                children: [
                  Expanded(
                    flex: 1,
                    child: ModernButton(
                      text: _startTime == null
                          ? 'Select Start'
                          : DateFormat('MMM d, yyyy h:mm a').format(_startTime!),
                      icon: Icons.calendar_today,
                      onPressed: () => _selectDateTime(context, true),
                      // Removed invalid textStyle parameter
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ModernButton(
                      text: _endTime == null
                          ? 'Select End'
                          : DateFormat('MMM d, yyyy h:mm a').format(_endTime!),
                      icon: Icons.calendar_today,
                      onPressed: () => _selectDateTime(context, false),
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 16),

                // Broadcast Toggle
                SwitchListTile(
                  title: const Text('Broadcast Shift'),
                  value: _broadcast,
                  onChanged: (value) {
                    setState(() {
                      _broadcast = value;
                    });
                  },
                  activeColor: AppTheme.successGreen,
                ),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: ModernButton(
                    text: 'Create Shift',
                    icon: Icons.add,
                    isLoading: _isLoading,
                    onPressed: _submitShift,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}