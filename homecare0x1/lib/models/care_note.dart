class CareNote {
  final String id;
  final String clientId;
  final String caregiverId;
  final String note;
  final DateTime timestamp;

  CareNote({
    required this.id,
    required this.clientId,
    required this.caregiverId,
    required this.note,
    required this.timestamp,
  });
}
