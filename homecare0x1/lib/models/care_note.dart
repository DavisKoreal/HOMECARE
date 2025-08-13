import 'package:uuid/uuid.dart';

class CareNote {
  final String id;
  final String clientId;
  final String caregiverId;
  final String shiftId;
  final String healthStatus;
  final String activities;
  final String observations;
  final String medicationAdherence;
  final String mood;
  final String note;
  final DateTime timestamp;
  final bool isVisibleToClient;
  final bool isLate;

  CareNote({
    String? id,
    required this.clientId,
    required this.caregiverId,
    required this.shiftId,
    required this.healthStatus,
    required this.activities,
    required this.observations,
    required this.medicationAdherence,
    required this.mood,
    required this.note,
    required this.timestamp,
    this.isVisibleToClient = false,
    this.isLate = false,
  }) : id = id ?? const Uuid().v4();
}
