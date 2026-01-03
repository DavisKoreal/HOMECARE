import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminInitiateShift extends StatefulWidget {
  final VoidCallback? onBack;
  const AdminInitiateShift({super.key, this.onBack});

  @override
  State<AdminInitiateShift> createState() => _AdminInitiateShiftState();
}

class _AdminInitiateShiftState extends State<AdminInitiateShift> {
  // Data
  List<Client> _clients = [];
  List<CaregiverProfile> _caregivers = [];
  
  // Selection
  String? _selectedClientId;
  String? _selectedClientName;
  String? _selectedCaregiverId;
  String? _selectedCaregiverName;
  
  // Form State
  DateTime? _startTime;
  DateTime? _endTime;
  bool _broadcast = false;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await FirebaseShiftService.instance.getAllClients();
      final caregivers = await FirebaseCaregiverService.instance.getAllCaregiverProfiles();
      if (mounted) {
        setState(() {
          _clients = clients;
          _caregivers = caregivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startTime = dt;
        // Auto-set end time to 8 hours later if not set
        if (_endTime == null) {
          _endTime = dt.add(const Duration(hours: 8));
        }
      } else {
        _endTime = dt;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedClientId == null) {
      _showError('Please select a client');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Please set start and end times');
      return;
    }
    if (!_broadcast && _selectedCaregiverId == null) {
      _showError('Please select a caregiver or enable broadcast');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseShiftService.instance.addShift(
        clientId: _selectedClientId!,
        clientName: _selectedClientName!,
        startTime: _startTime!,
        endTime: _endTime!,
        context: context,
        caregiverId: _selectedCaregiverId,
        caregiverName: _selectedCaregiverName,
        broadcast: _broadcast,
        adminNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift created successfully'), backgroundColor: AppTheme.successGreen),
        );
        _handleBack();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Single Page Form Layout
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Shift',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assign a caregiver to a client.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: _handleBack),
                ],
              ),
              const Divider(height: 48),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else ...[
                // 1. Client Selection
                _buildLabel('Client Recipient'),
                DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  hint: const Text('Select Client'),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: _clients.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClientId = val;
                      _selectedClientName = _clients.firstWhere((c) => c.id == val).name;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 2. Time Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Time'),
                          InkWell(
                            onTap: () => _selectDateTime(true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderGray),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    _startTime != null 
                                      ? DateFormat('MMM d, h:mm a').format(_startTime!) 
                                      : 'Select Start',
                                    style: TextStyle(
                                      color: _startTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Time'),
                          InkWell(
                            onTap: () => _selectDateTime(false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderGray),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, size: 18, color: AppTheme.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    _endTime != null 
                                      ? DateFormat('MMM d, h:mm a').format(_endTime!) 
                                      : 'Select End',
                                    style: TextStyle(
                                      color: _endTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Caregiver Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Caregiver Assignment'),
                    Row(
                      children: [
                        Checkbox(
                          value: _broadcast, 
                          activeColor: AppTheme.primaryPurple,
                          onChanged: (val) => setState(() {
                            _broadcast = val!;
                            if (val) {
                              _selectedCaregiverId = null;
                              _selectedCaregiverName = null;
                            }
                          }),
                        ),
                        const Text('Broadcast to all available'),
                      ],
                    ),
                  ],
                ),
                if (!_broadcast)
                  DropdownButtonFormField<String>(
                    value: _selectedCaregiverId,
                    hint: const Text('Select Caregiver'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _caregivers.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} (${c.role})'),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCaregiverId = val;
                        _selectedCaregiverName = _caregivers.firstWhere((c) => c.id == val).name;
                      });
                    },
                  ),
                
                const SizedBox(height: 24),

                // 4. Notes
                _buildLabel('Notes (Optional)'),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter specific instructions for this shift...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _handleBack,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Publish Shift'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}
