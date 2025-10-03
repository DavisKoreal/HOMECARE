import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';

// Main Page Widget
class AdminCaregiverApprovalPage extends StatefulWidget {
  final String adminId;

  const AdminCaregiverApprovalPage({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  State<AdminCaregiverApprovalPage> createState() =>
      _AdminCaregiverApprovalPageState();
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
    setState(() {
      _unapprovedCaregivers = caregivers;
      _isLoading = false;
    });
  }

  void _showCaregiverDetails(CaregiverProfile caregiver) {
    showDialog(
      context: context,
      builder: (context) => CaregiverDetailsDialog(
        caregiver: caregiver,
        onApprove: () => _handleApproval(caregiver),
      ),
    );
  }

  Future<void> _handleApproval(CaregiverProfile caregiver) async {
    Navigator.of(context).pop(); // Close details dialog

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApprovalConfirmationDialog(
        adminId: widget.adminId,
        caregiverName: caregiver.name,
      ),
    );

    if (confirmed == true) {
      _performApproval(caregiver);
    }
  }

  Future<void> _performApproval(CaregiverProfile caregiver) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _service.upsertApprovalStatus(
      caregiver.id,
      true,
      widget.adminId,
    );

    Navigator.of(context).pop(); // Close loading dialog

    if (result == "success") {
      _showResultDialog(
        'Success',
        '${caregiver.name} has been approved successfully.',
        Icons.check_circle,
        Colors.green,
      );
      await _loadUnapprovedCaregivers();
    } else {
      _showResultDialog(
        'Error',
        'Failed to approve caregiver. Please try again.',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showResultDialog(
      String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Approval'),
        elevation: 2,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _unapprovedCaregivers.isEmpty
              ? const EmptyStateWidget()
              : CaregiverListWidget(
                  caregivers: _unapprovedCaregivers,
                  onCaregiverTap: _showCaregiverDetails,
                ),
    );
  }
}

// Loading Widget Module
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// Empty State Widget Module
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          Text(
            'All caregivers have been approved!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending approvals at this time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

// Caregiver List Widget Module
class CaregiverListWidget extends StatelessWidget {
  final List<CaregiverProfile> caregivers;
  final Function(CaregiverProfile) onCaregiverTap;

  const CaregiverListWidget({
    Key? key,
    required this.caregivers,
    required this.onCaregiverTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: caregivers.length,
      itemBuilder: (context, index) {
        final caregiver = caregivers[index];
        return CaregiverListItem(
          caregiver: caregiver,
          onTap: () => onCaregiverTap(caregiver),
        );
      },
    );
  }
}

// Caregiver List Item Module
class CaregiverListItem extends StatelessWidget {
  final CaregiverProfile caregiver;
  final VoidCallback onTap;

  const CaregiverListItem({
    Key? key,
    required this.caregiver,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            caregiver.name.isNotEmpty ? caregiver.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          caregiver.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(caregiver.role),
            const SizedBox(height: 2),
            Text(
              'Experience: ${caregiver.experience}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// Caregiver Details Dialog Module
class CaregiverDetailsDialog extends StatelessWidget {
  final CaregiverProfile caregiver;
  final VoidCallback onApprove;

  const CaregiverDetailsDialog({
    Key? key,
    required this.caregiver,
    required this.onApprove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Caregiver Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: CaregiverDetailsContent(caregiver: caregiver),
            ),
          ),
          // Approve Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Approve Caregiver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Caregiver Details Content Module
class CaregiverDetailsContent extends StatelessWidget {
  final CaregiverProfile caregiver;

  const CaregiverDetailsContent({
    Key? key,
    required this.caregiver,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('Name', caregiver.name),
        _buildDetailSection('Role', caregiver.role),
        _buildDetailSection('Experience', caregiver.experience),
        _buildDetailSection('Phone', caregiver.phone),
        _buildDetailSection('Email', caregiver.email),
        _buildDetailSection('Bio', caregiver.bio),
        _buildListSection('Certifications', caregiver.certifications),
        _buildListSection('Availability', caregiver.availability),
        _buildRatingSection(context),
      ],
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            const Text(
              'None provided',
              style: TextStyle(fontSize: 16),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${caregiver.rating.toStringAsFixed(1)} (${caregiver.reviews} reviews)',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Approval Confirmation Dialog Module
class ApprovalConfirmationDialog extends StatelessWidget {
  final String adminId;
  final String caregiverName;

  const ApprovalConfirmationDialog({
    Key? key,
    required this.adminId,
    required this.caregiverName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Confirm Approval'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to approve $caregiverName as a certified caregiver on the platform. Caregivers are verified professionals who provide essential care services to clients. By approving this caregiver, you confirm that they meet the necessary qualifications and standards required to offer care services.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Note that your user ID on our platform will be recorded together with the approval.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your ID: $adminId",
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Do you want to continue?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}