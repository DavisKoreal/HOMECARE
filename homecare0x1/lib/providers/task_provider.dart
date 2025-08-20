import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    try {
      // final snapshot = await _firestore.collection('tasks').get();
      final snapshot = await _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();
      _tasks.clear();
      _tasks.addAll(snapshot.docs.map((doc) => Task(
        id: doc.id,
        title: doc['title'],
        dueDate: (doc['dueDate'] as Timestamp).toDate(),
        isCompleted: doc['isCompleted'],
        clientId: doc['clientId'],
        clientName: doc['clientName'],
        description: doc['description'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': !task.isCompleted,
      });
      task.isCompleted = !task.isCompleted;
      notifyListeners();
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }
}
