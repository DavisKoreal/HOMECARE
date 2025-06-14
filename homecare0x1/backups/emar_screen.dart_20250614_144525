import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/medication_record.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class EmarScreen extends StatefulWidget {
  const EmarScreen({super.key});

  @override
  _EmarScreenState createState() => _EmarScreenState();
}

class _EmarScreenState extends State<EmarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isAdding = false;

  // Mock medication records
  List<MedicationRecord> _records = [
    MedicationRecord(
      id: '1',
      clientId: '1',
      medicationName: 'Aspirin',
      dosage: '100mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Taken with water',
    ),
    MedicationRecord(
      id: '2',
      clientId: '1',
      medicationName: 'Lisinopril',
      dosage: '10mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'No side effects',
    ),
  ];

  void _toggleAddForm() {
    setState(() {
      _isAdding = !_isAdding;
      if (!_isAdding) {
        _medicationController.clear();
        _dosageController.clear();
        _notesController.clear();
      }
    });
  }

  void _addRecord() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _records.insert(
          0,
          MedicationRecord(
            id: (_records.length + 1).toString(),
            clientId: '1',
            medicationName: _medicationController.text,
            dosage: _dosageController.text,
            administrationTime: DateTime.now(),
            notes: _notesController.text,
          ),
        );
        _toggleAddForm();
      });
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'eMAR',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Administration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Log and view medication records',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: _isAdding ? 'Cancel' : 'Add Medication',
              icon: _isAdding ? Icons.cancel : Icons.add,
              width: double.infinity,
              isOutlined: _isAdding,
              onPressed: _toggleAddForm,
            ),
            if (_isAdding) ...[
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _medicationController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter medication name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter dosage' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ModernButton(
                      text: 'Log Medication',
                      icon: Icons.save,
                      width: double.infinity,
                      onPressed: _addRecord,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Medication History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _records.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(record.medicationName),
                          subtitle: Text(
                            'Dosage: ${record.dosage}\nTime: ${DateFormat('MMM d, h:mm a').format(record.administrationTime)}\nNotes: ${record.notes}',
                          ),
                          leading: Icon(
                            Icons.medical_services,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Check-In',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
