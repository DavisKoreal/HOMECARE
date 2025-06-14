import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  // Mock data for demonstration; replace with API call in production
  Future<List<Client>> _fetchClients() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      Client(
          id: '1',
          name: 'Alice Smith',
          email: 'alice@example.com',
          address: '123 Main St',
          carePlan: 'Comprehensive Care'),
      Client(
          id: '2',
          name: 'Bob Johnson',
          email: 'bob@example.com',
          address: '456 Elm St',
          carePlan: 'Standard Care'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client List'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Client>>(
        future: _fetchClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final clients = snapshot.data ?? [];
          if (clients.isEmpty) {
            return const Center(child: Text('No clients found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      client.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    client.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    client.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutral600,
                        ),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.clientProfile,
                    arguments: client,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
