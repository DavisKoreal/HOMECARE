import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/task.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Mock task data
  List<Task> _tasks = [
    Task(
      id: '1',
      clientId: '1',
      title: 'Morning Medication',
      description: 'Administer prescribed medication',
      dueDate: DateTime.now().add(const Duration(hours: 1)),
    ),
    Task(
      id: '2',
      clientId: '1',
      title: 'Mobility Assistance',
      description: 'Help with morning walk',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    Task(
      id: '3',
      clientId: '1',
      title: 'Meal Preparation',
      description: 'Prepare breakfast',
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index] = Task(
        id: _tasks[index].id,
        clientId: _tasks[index].clientId,
        title: _tasks[index].title,
        description: _tasks[index].description,
        isCompleted: !_tasks[index].isCompleted,
        dueDate: _tasks[index].dueDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Task List',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Tasks',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage tasks for the current client visit',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(index),
                        activeColor: AppTheme.successGreen,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${task.description}\nDue: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                      ),
                      trailing: Icon(
                        Icons.task,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  );
                },
              ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Implement add task functionality
        },
      ),
    );
  }
}
