import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/location.dart';

class Shift {
  final String id;
  final String clientId;
  String clientName;
  DateTime startTime;
  DateTime endTime;
  String? caregiverId;
  String? caregiverName;
  String status; // 'pending', 'in_session', 'completed', 'cancelled', 'request'
  Location? location;
  bool? broadcast;

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
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'caregiverId': caregiverId,
      'caregiverName': caregiverName,
      'status': status,
      'location': location != null
          ? {'latitude': location!.latitude, 'longitude': location!.longitude}
          : null,
      'broadcast': broadcast,
    };
  }

  // Create from Firestore document
  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      caregiverId: map['caregiverId'],
      caregiverName: map['caregiverName'],
      status: map['status'] ?? 'pending',
      location: map['location'] != null
          ? Location(
              latitude: (map['location']['latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (map['location']['longitude'] as num?)?.toDouble() ?? 0.0,
            )
          : null,
      broadcast: map['broadcast'] as bool?,
    );
  }

  // Copy with method for immutable updates
  Shift copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? startTime,
    DateTime? endTime,
    String? caregiverId,
    String? caregiverName,
    String? status,
    Location? location,
    bool? broadcast,
  }) {
    return Shift(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      caregiverId: caregiverId ?? this.caregiverId,
      caregiverName: caregiverName ?? this.caregiverName,
      status: status ?? this.status,
      location: location ?? this.location,
      broadcast: broadcast ?? this.broadcast,
    );
  }
}