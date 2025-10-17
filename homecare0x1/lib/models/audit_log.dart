class AuditLog {

  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String action;
  final DateTime timestamp;
  final String details;
  final String actionType;
  final String severity; 

  AuditLog._({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.timestamp,
    required this.details,
    required this.actionType,
    required this.severity,
  });

   
  static const validActionTypes = [
    'login',
    'logout',
    'data change',
    'security',
    'compliance',
    'assignment',
    'add care note',
    'shift request',
    'check in', 
    'check out',
  ];

  static const validSeverities = [
    'info',
    'warning',
    'error',
    'critical',
    'security',
    'compliance'
  ];

  factory AuditLog({
    required String id,
    required String userId,
    required String userName,
    required String userRole, // Default role is 'user'
    required String action,
    required DateTime timestamp,
    required String details,
    required String actionType,
    required String severity,
  }) {
    // Validate actionType

    if (!validActionTypes.contains(actionType)) {
      throw ArgumentError('Invalid actionType: $actionType. This error is because there is an action that ahs beemn entered taht is not part of the enums tahta have benn estated in the descripption Must be one of $validActionTypes');
    }

    // Validate severity

    if (!validSeverities.contains(severity)) {
      throw ArgumentError('Invalid severity: $severity. The entered actions are not available. Must be one of $validSeverities');
    }

    return AuditLog._(
      id: id,
      userId: userId,
      userName: userName,
      userRole: userRole,// User role can be set later if needed
      action: action,
      timestamp: timestamp,
      details: details,
      actionType: actionType,
      severity: severity,
    );
  }
}
//this is the class that defines what the audit log model does, its attributes and stuff important for 
//the functions that consume such objects ijn the whole project.