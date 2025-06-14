import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class ClientListScreen extends StatelessWidget {
  ClientListScreen({super.key});

  // Mock client data
  final List<Map<String, String>> _clients = [
    {
      'id': '1',
      'name': 'John Doe',
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'status': 'Active',
    },
    {
      'id': '3',
      'name': 'Alice Johnson',
      'status': 'Inactive',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Client List',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, Routes.adminDashboard),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clients',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View your assigned clients',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _clients.isEmpty
                ? const Center(child: Text('No clients found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _clients.length,
                    itemBuilder: (context, index) {
                      final client = _clients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(client['name']!),
                          subtitle: Text('Status: ${client['status']}'),
                          leading: const Icon(
                            Icons.person,
                            color: AppTheme.primaryBlue,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.clientProfile,
                              arguments: client['id'],
                            );
                          },
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
