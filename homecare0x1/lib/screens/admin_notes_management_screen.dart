import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/services/firebase_care_note_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class AdminNotesManagementScreen extends StatefulWidget {
  const AdminNotesManagementScreen({super.key});

  @override
  State<AdminNotesManagementScreen> createState() =>
      _AdminNotesManagementScreenState();
}

class _AdminNotesManagementScreenState extends State<AdminNotesManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final FirebaseCareNotesService _careNotesService = FirebaseCareNotesService();
  List<CareNote> _notes = [];
  Map<String, String> _clientNames = {};
  bool _isLoading = false;
  String? _error;
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _caregiverIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    // Fetch initial data
    _fetchInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _clientNameController.dispose();
    _clientIdController.dispose();
    _caregiverIdController.dispose();
    super.dispose();
  }

  /// Fetches initial data (all notes and client names)
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _notes = await _careNotesService.getAllCareNotes();
      try {
        _clientNames = await _careNotesService.getClientNames();
      } catch (e) {
        print('Failed to fetch client names: $e');
        // Continue without client names, use clientId as fallback
        _clientNames = {};
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  /// Fetches filtered care notes based on user input
  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? clientId = _clientIdController.text.trim().isEmpty
          ? null
          : _clientIdController.text.trim();
      String? caregiverId = _caregiverIdController.text.trim().isEmpty
          ? null
          : _caregiverIdController.text.trim();

      // Fetch filtered notes from Firestore
      List<CareNote> filteredNotes = await _careNotesService.getFilteredCareNotes(
        clientId: clientId,
        caregiverId: caregiverId,
        date: _selectedDate,
      );

      // Apply client name filter client-side
      String clientNameFilter = _clientNameController.text.trim().toLowerCase();
      if (clientNameFilter.isNotEmpty) {
        filteredNotes = filteredNotes.where((note) {
          String? clientName = _clientNames[note.clientId]?.toLowerCase();
          return clientName != null && clientName.contains(clientNameFilter);
        }).toList();
      }

      setState(() {
        _notes = filteredNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to apply filters: $e';
      });
    }
  }

  /// Toggles the visibility of a care note
  Future<void> _toggleVisibility(String noteId, bool currentVisibility) async {
    try {
      final newVisibility = !currentVisibility;
      await _careNotesService.toggleNoteVisibility(noteId, newVisibility);
      setState(() {
        _notes = _notes.map((note) {
          if (note.id == noteId) {
            return CareNote(
              id: note.id,
              clientId: note.clientId,
              caregiverId: note.caregiverId,
              shiftId: note.shiftId,
              healthStatus: note.healthStatus,
              activities: note.activities,
              observations: note.observations,
              medicationAdherence: note.medicationAdherence,
              mood: note.mood,
              note: note.note,
              timestamp: note.timestamp,
              isVisibleToClient: newVisibility,
              isLate: note.isLate,
            );
          }
          return note;
        }).toList();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to toggle visibility: $e';
      });
    }
  }

  /// Shows date picker for selecting filter date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilters();
    }
  }

  Widget _buildNoteCard(CareNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    note.isLate ? Icons.warning : Icons.note,
                    color:
                        note.isLate ? AppTheme.errorRed : AppTheme.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(note.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                if (note.isLate)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Late',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Client: ${_clientNames[note.clientId] ?? note.clientId}',
                style: const TextStyle(fontSize: 14)),
            Text('Client ID: ${note.clientId}',
                style: const TextStyle(fontSize: 14)),
            Text('Caregiver ID: ${note.caregiverId}',
                style: const TextStyle(fontSize: 14)),
            Text('Shift ID: ${note.shiftId}',
                style: const TextStyle(fontSize: 14)),
            Text('Health Status: ${note.healthStatus}',
                style: const TextStyle(fontSize: 14)),
            Text('Activities: ${note.activities}',
                style: const TextStyle(fontSize: 14)),
            Text('Observations: ${note.observations}',
                style: const TextStyle(fontSize: 14)),
            Text('Medication Adherence: ${note.medicationAdherence}',
                style: const TextStyle(fontSize: 14)),
            Text('Mood: ${note.mood}', style: const TextStyle(fontSize: 14)),
            Text('Note: ${note.note}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ModernButton(
              text: note.isVisibleToClient
                  ? 'Hide from Client'
                  : 'Show to Client',
              icon: note.isVisibleToClient
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppTheme.primaryBlue,
              onPressed: () {
                _toggleVisibility(note.id, note.isVisibleToClient);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.note,
                color: AppTheme.successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Manage Notes',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00A86B),
                        Color(0xFF00C975),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Daily Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'View and control visibility of all care notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _clientNameController,
                        decoration: InputDecoration(
                          labelText: 'Client Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _clientIdController,
                        decoration: InputDecoration(
                          labelText: 'Client ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _caregiverIdController,
                        decoration: InputDecoration(
                          labelText: 'Caregiver ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate!),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          ModernButton(
                            text: 'Pick Date',
                            icon: Icons.calendar_today,
                            color: AppTheme.primaryBlue,
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      if (_selectedDate != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                            });
                            _applyFilters();
                          },
                          child: const Text('Clear Date'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'All Notes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Column(
                            children: [
                              Center(child: Text('Error: $_error')),
                              const SizedBox(height: 16),
                              ModernButton(
                                text: 'Retry',
                                icon: Icons.refresh,
                                color: AppTheme.primaryBlue,
                                onPressed: _fetchInitialData,
                              ),
                            ],
                          )
                        : _notes.isEmpty
                            ? const Center(child: Text('No notes available'))
                            : Column(
                                children: _notes
                                    .map((note) => _buildNoteCard(note))
                                    .toList(),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}