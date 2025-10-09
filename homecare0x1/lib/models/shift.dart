import 'package:homecare0x1/models/location.dart';

class Shift {
  final String id;
  final String clientId;
  String clientName;
  DateTime startTime;
  DateTime endTime;
  String? caregiverId;
  String? caregiverName;
  String status; // 'pending', 'in_session', 'completed', 'cancelled', 'request',
  Location? location; // Optional location for the shift
  bool? broadcast;
  String? adminNotes;

 
  Shift({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.startTime,
    required this.endTime,
    this.caregiverId,
    this.caregiverName,
    required this.status,
    this.location,
    this.broadcast,
    this.adminNotes,
  });
}