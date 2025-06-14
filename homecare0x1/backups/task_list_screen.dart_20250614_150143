import 'package:flutter/material.dart';
import 'package:homecare0x1/models/task.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  // Mock data for demonstration; replace with API call in production
  Future<List<Task>> _fetchTasks() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      Task(
          id: '1',
          title: 'Check Vitals',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          isCompleted: false,
          clientId: '1',
          description: 'Check blood pressure and heart rate'),
      Task(
          id: '2',
          title: 'Medication Admin',
          dueDate: DateTime.now().add(const Duration(hours: 4)),
          isCompleted: true,
          clientId: '1',
          description: 'Administer morning medications'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Task>>(
        future: _fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks assigned'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      // TODO: Update task status
                    },
                    activeColor: AppTheme.successGreen,
                  ),
                  title: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  subtitle: Text(
                    'Due: ${task.dueDate.toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutral600,
                        ),
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
