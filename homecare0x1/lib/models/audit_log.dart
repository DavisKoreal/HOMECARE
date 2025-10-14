class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final String details;
  final String actionType;
  final String severity;

  AuditLog({
    required this.id,
    required this.userName,
    required this.userId,
    required this.action,
    required this.timestamp,
    required this.details,
    required this.actionType,
    required this.severity,
  });
}
