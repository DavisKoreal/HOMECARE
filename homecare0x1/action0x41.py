import os

def fix_error_communication():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update FirebaseShiftService to return actual error messages
    # ---------------------------------------------------------
    print("\n--- Updating lib/services/firebase_shift_service.dart ---")
    service_path = os.path.join("lib", "services", "firebase_shift_service.dart")
    
    with open(service_path, "r", encoding="utf-8") as f:
        service_content = f.read()

    # We need to change the catch block in addShift to return e.toString() instead of "error"
    # To be safe, we'll replace the catch block pattern for addShift
    
    # Old pattern:
    # } catch (e) {
    #   // Log error and return error status
    #   print('Error adding shift: $e');
    #   return "error";
    # }

    # New pattern:
    # } catch (e) {
    #   print('Error adding shift: $e');
    #   return e.toString();
    # }

    if 'return "error";' in service_content:
        service_content = service_content.replace(
            'return "error";', 
            'return e.toString();'
        )
    
    with open(service_path, "w", encoding="utf-8") as f:
        f.write(service_content)
    print("Updated FirebaseShiftService to propagate error messages.")

    # ---------------------------------------------------------
    # 2. Update AdminInitiateShift to handle the return value
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_initiate_shift.dart ---")
    screen_path = os.path.join("lib", "screens", "admin_initiate_shift.dart")
    
    with open(screen_path, "r", encoding="utf-8") as f:
        screen_content = f.read()

    # We need to replace the _submit method logic.
    # Specifically, we need to capture the result and check it.
    
    # Current (problematic) call:
    # await FirebaseShiftService.instance.addShift(...)
    # if (mounted) { ... success ... }

    # New logic:
    # final result = await FirebaseShiftService.instance.addShift(...)
    # if (result == 'success') { ... success ... } else { _showError(result); }

    # Because regex replacement of large blocks can be fragile, I will locate the specific call and surrounding block.
    # The call starts with "await FirebaseShiftService.instance.addShift("
    
    if "await FirebaseShiftService.instance.addShift(" in screen_content:
        # We also want to add the pre-check for time as a bonus UX improvement
        
        new_submit_logic = """
    // Pre-Validation (Bonus UX)
    if (_startTime!.isBefore(DateTime.now())) {
      _showError('Start time must be in the future');
      return;
    }

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
        adminNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shift created successfully'), backgroundColor: AppTheme.successGreen),
          );
          _handleBack();
        } else {
          // Clean up the exception message for display
          String msg = result.replaceAll('Exception: ', '');
          _showError(msg);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }
"""
        # We need to replace the entire _submit body. 
        # I will replace the specific section from "setState(() => _isLoading = true);" down to the end of the original try block.
        # However, purely textual replacement is hard. 
        # I'll rewrite the file using the full content strategy to ensure 100% accuracy.
        
        full_new_content = """import 'package:flutter/material.dart';
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

    // Client-side Validation for immediate feedback
    if (_startTime!.isBefore(DateTime.now())) {
      _showError('Start time must be in the future');
      return;
    }

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
        adminNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shift created successfully'), backgroundColor: AppTheme.successGreen),
          );
          _handleBack();
        } else {
          // Display the specific error returned by the service
          String errorMsg = result.replaceAll('Exception: ', '');
          _showError(errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
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
"""
        with open(screen_path, "w", encoding="utf-8") as f:
            f.write(full_new_content)
        print("Updated AdminInitiateShift to check return value and show errors.")

if __name__ == "__main__":
    fix_error_communication()