import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class AdminCaregiverApprovalPage extends StatefulWidget {
  final String adminId;

  const AdminCaregiverApprovalPage({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  State<AdminCaregiverApprovalPage> createState() => _AdminCaregiverApprovalPageState();
}

class _AdminCaregiverApprovalPageState extends State<AdminCaregiverApprovalPage> {
  final FirebaseCaregiverService _service = FirebaseCaregiverService.instance;
  List<CaregiverProfile> _unapprovedCaregivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnapprovedCaregivers();
  }

  Future<void> _loadUnapprovedCaregivers() async {
    setState(() => _isLoading = true);
    final caregivers = await _service.getUnApprovedCaregivers();
    if (mounted) {
      setState(() {
        _unapprovedCaregivers = caregivers;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(CaregiverProfile caregiver) async {
    setState(() => _isLoading = true);
    final result = await _service.upsertApprovalStatus(
      caregiver.id,
      true,
      widget.adminId,
    );
    
    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${caregiver.name} approved'), backgroundColor: AppTheme.successGreen)
      );
      await _loadUnapprovedCaregivers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve'), backgroundColor: AppTheme.errorRed)
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
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
                    'Staff Approvals',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review and approve new caregiver registrations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUnapprovedCaregivers,
                tooltip: 'Refresh List',
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (_unapprovedCaregivers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successGreen),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('There are no pending approvals at this time.', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unapprovedCaregivers.length,
              itemBuilder: (context, index) {
                final c = _unapprovedCaregivers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(c.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.role, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(c.phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _approve(c),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
