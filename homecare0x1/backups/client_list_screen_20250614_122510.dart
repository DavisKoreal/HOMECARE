import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class ClientListScreen extends StatelessWidget {
  ClientListScreen({super.key});

  // Mock client data
  final List<Client> _clients = [
    Client(
        id: '1',
        name: 'John Doe',
        address: '123 Main St',
        carePlan: 'Daily care'),
    Client(
        id: '2',
        name: 'Jane Smith',
        address: '456 Oak Ave',
        carePlan: 'Weekly check-in'),
    Client(
        id: '3',
        name: 'Alice Johnson',
        address: '789 Pine Rd',
        carePlan: 'Hourly assistance'),
  ];

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Client List',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clients',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage all client profiles',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(client.name),
                      subtitle: Text(client.address),
                      trailing: Icon(Icons.arrow_forward,
                          color: AppTheme.primaryBlue),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.clientProfile),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Dashboard',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Implement add client functionality
        },
      ),
    );
  }
}
