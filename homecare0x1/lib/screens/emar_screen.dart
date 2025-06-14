import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/medication_record.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/medication_record_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmarScreen extends StatelessWidget {
  const EmarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationRecordProvider>(context);
    final records = medicationProvider.records;

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
              'View medication records',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            records.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
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
