import 'package:flutter/material.dart';
import 'package:homecare0x1/models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Check Vitals',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      isCompleted: false,
      clientId: '1',
      clientName: 'John Doe',
      description: 'Check blood pressure and heart rate',
    ),
    Task(
      id: '2',
      title: 'Medication Admin',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      isCompleted: true,
      clientId: '1',
      clientName: 'John Doe',
      description: 'Administer morning medications',
    ),
    Task(
      id: '3',
      title: 'Physical Therapy',
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      isCompleted: false,
      clientId: '2',
      clientName: 'Jane Smith',
      description: 'Assist with mobility exercises',
    ),
    Task(
      id: '4',
      title: 'Meal Prep',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      clientId: '3',
      clientName: 'Alice Johnson',
      description: 'Prepare lunch and dinner',
    ),
  ];

  List<Task> get tasks => _tasks;

  void toggleTaskCompletion(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }
}
