class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  bool isCompleted;
  final String clientId;
  final String clientName;
  final String description;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    required this.clientId,
    required this.clientName,
    required this.description,
  });
}
