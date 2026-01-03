import os

def fix_spa_navigation():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update Admin Add Caregiver (Add onBack)
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_add_caregiver.dart ---")
    caregiver_path = os.path.join("lib", "screens", "admin_add_caregiver.dart")
    
    caregiver_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class AdminAddCaregiverPage extends StatefulWidget {
  final VoidCallback? onBack;
  const AdminAddCaregiverPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<AdminAddCaregiverPage> createState() => _AdminAddCaregiverPageState();
}

class _AdminAddCaregiverPageState extends State<AdminAddCaregiverPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _certInputController = TextEditingController();
  final _availInputController = TextEditingController();

  final List<String> _certifications = [];
  final List<String> _availability = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _certInputController.dispose();
    _availInputController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  void _addToList(TextEditingController controller, List<String> list) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profile = CaregiverProfile(
      id: '',
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      experience: _experienceController.text.trim(),
      certifications: _certifications,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      availability: _availability,
      rating: 0.0,
      reviews: 0,
      approved: false,
      approverId: null,
    );

    try {
      final result = await FirebaseCaregiverService.instance.createCaregiver(profile);
      
      if (!mounted) return;

      if (result.startsWith('Error')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: AppTheme.errorRed));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caregiver added successfully'), backgroundColor: AppTheme.successGreen));
        _handleBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Care Staff',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _handleBack,
                    )
                  ],
                ),
                const Divider(height: 48),

                // Grid Layout for inputs
                LayoutBuilder(builder: (context, constraints) {
                  // If wide enough, put Name/Role side by side
                  bool isWide = constraints.maxWidth > 500;
                  return Column(
                    children: [
                      _buildResponsiveRow([
                        _buildInputGroup('Full Name', _nameController, 'Required'),
                        _buildInputGroup('Role / Title', _roleController, 'e.g. Nurse, Aid'),
                      ], isWide),
                      const SizedBox(height: 24),
                      _buildResponsiveRow([
                        _buildInputGroup('Email', _emailController, 'Required', TextInputType.emailAddress),
                        _buildInputGroup('Phone', _phoneController, 'Required', TextInputType.phone),
                      ], isWide),
                    ],
                  );
                }),
                
                const SizedBox(height: 24),
                _buildLabel('Experience'),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(hintText: 'e.g. 5 years in elderly care'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),
                _buildLabel('Biography'),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Brief professional summary...'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Dynamic Lists (Certifications)
                _buildDynamicListInput(
                  'Certifications', 
                  _certInputController, 
                  _certifications, 
                  'Add Certification'
                ),

                const SizedBox(height: 24),

                // Dynamic Lists (Availability)
                _buildDynamicListInput(
                  'Availability', 
                  _availInputController, 
                  _availability, 
                  'Add Slot (e.g. Mon 9-5)'
                ),

                const SizedBox(height: 40),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _handleBack,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Caregiver'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, String hint, [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildResponsiveRow(List<Widget> children, bool isWide) {
    if (!isWide) {
      return Column(
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 24),
        Expanded(child: children[1]),
      ],
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

  Widget _buildDynamicListInput(String title, TextEditingController controller, List<String> list, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
                onFieldSubmitted: (_) => _addToList(controller, list),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () => _addToList(controller, list),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: AppTheme.primaryPurple.withOpacity(0.1), foregroundColor: AppTheme.primaryPurple),
            )
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value),
              backgroundColor: AppTheme.backgroundCanvas,
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => list.removeAt(entry.key)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
                side: const BorderSide(color: AppTheme.borderGray)
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
"""
    with open(caregiver_path, "w", encoding="utf-8") as f:
        f.write(caregiver_content)
    print("Updated admin_add_caregiver.dart")

    # ---------------------------------------------------------
    # 2. Update Admin Add Client (Add onBack)
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_add_client.dart ---")
    client_path = os.path.join("lib", "screens", "admin_add_client.dart")
    
    client_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/services/client_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/constants.dart';

class AdminAddClientScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AdminAddClientScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<AdminAddClientScreen> createState() => _AdminAddClientScreenState();
}

class _AdminAddClientScreenState extends State<AdminAddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _carePlanController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _carePlanController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final client = Client(
      id: '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      carePlan: _carePlanController.text.trim(),
    );

    try {
      final result = await FirebaseClientService.instance.createClient(client);

      if (!mounted) return;

      if (result.startsWith('Error')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: AppTheme.errorRed));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client added successfully'), backgroundColor: AppTheme.successGreen));
        _handleBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centered Form Container for Desktop Aesthetics
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Client',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _handleBack,
                    )
                  ],
                ),
                const Divider(height: 48),

                // Form Fields
                _buildLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. John Doe'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Email Address'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'e.g. john@example.com'),
                  validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Physical Address'),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Enter full address'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Care Plan Details'),
                TextFormField(
                  controller: _carePlanController,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Describe needs, medication, schedule...'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 40),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _handleBack,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Client'),
                    ),
                  ],
                ),
              ],
            ),
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
    with open(client_path, "w", encoding="utf-8") as f:
        f.write(client_content)
    print("Updated admin_add_client.dart")

    # ---------------------------------------------------------
    # 3. Update Admin Initiate Shift (Add onBack)
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_initiate_shift.dart ---")
    shift_path = os.path.join("lib", "screens", "admin_initiate_shift.dart")
    
    shift_content = """import 'package:flutter/material.dart';
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
"""
    with open(shift_path, "w", encoding="utf-8") as f:
        f.write(shift_content)
    print("Updated admin_initiate_shift.dart")

    # ---------------------------------------------------------
    # 4. Update Dashboard Controller to Pass Callback
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "admin_dashboard.dart")
    
    # We update the _getViewForRoute method to inject the navigation callback
    dashboard_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/widgets/dashboard_shell.dart';
import 'package:homecare0x1/theme/app_theme.dart';

// Import All Screens that need to be shown in the content area
import 'package:homecare0x1/screens/admin_overview_view.dart';
import 'package:homecare0x1/screens/admin_calendar_screen.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/admin_notes_management_screen.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/admin_initiate_shift.dart';
import 'package:homecare0x1/screens/admin_add_client.dart';
import 'package:homecare0x1/screens/admin_add_caregiver.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // State: The currently active route in the content area
  String _currentRoute = Routes.adminDashboard;

  // Method to switch views (passed down to children)
  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: _getTitleForRoute(_currentRoute),
      activeRoute: _currentRoute,
      onNavigate: _navigateTo, // Pass the callback to the Shell
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
        ),
      ],
      // The body of the Shell is now dynamic based on _currentRoute
      content: _getViewForRoute(_currentRoute),
    );
  }

  // Helper to determine the Page Title
  String _getTitleForRoute(String route) {
    switch (route) {
      case Routes.adminDashboard: return 'Overview';
      case Routes.adminCalendar: return 'Calendar';
      case Routes.shiftAssignment: return 'Shift Assignments';
      case Routes.clientList: return 'Recipients';
      case Routes.adminNotesManagement: return 'Care Notes';
      case Routes.auditLog: return 'System Logs';
      case Routes.adminInitiateShift: return 'New Shift';
      case Routes.adminAddClient: return 'Add Recipient';
      case Routes.adminAddCaregiver: return 'Add Staff';
      case Routes.adminCaregiverApproval: return 'Staff Approval';
      default: return 'HomeCare';
    }
  }

  // Helper to return the correct Widget
  Widget _getViewForRoute(String route) {
    // Note: We wrap secondary screens in a ClipRect or similar if needed, 
    // but standard widgets work fine in the Expanded content area.
    switch (route) {
      case Routes.adminDashboard:
        return AdminOverviewView(onNavigate: _navigateTo);
        
      case Routes.adminCalendar:
        return const AdminCalendarScreen();
        
      case Routes.shiftAssignment:
        return const ShiftAssignmentScreen();
        
      case Routes.clientList:
        return const ClientListScreen();
        
      case Routes.adminNotesManagement:
        return const AdminNotesManagementScreen();
        
      case Routes.auditLog:
        return const AuditLogScreen();

      case Routes.adminInitiateShift:
        // Pass the callback so the form can close itself properly
        return AdminInitiateShift(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminAddClient:
        return AdminAddClientScreen(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminAddCaregiver:
        return AdminAddCaregiverPage(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminCaregiverApproval:
        final adminId = Provider.of<UserProvider>(context, listen: false).user?.id ?? '';
        return AdminCaregiverApprovalPage(adminId: adminId);

      default:
        return Center(child: Text("Page not found for $route"));
    }
  }
}
"""
    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dashboard_content)
    print("Updated admin_dashboard.dart (Controller).")

if __name__ == "__main__":
    fix_spa_navigation()