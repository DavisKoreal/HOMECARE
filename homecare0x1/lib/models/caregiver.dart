import 'package:cloud_firestore/cloud_firestore.dart';

class Caregiver {
  final String id;
  final String name;
  final String employeeID;
  final bool isAvailable;
  final DateTime? startExperience;

  Caregiver({
    required this.id,
    required this.name,
    required this.employeeID,
    required this.isAvailable,
    this.startExperience,
  });

  factory Caregiver.fromMap(Map<String, dynamic> map, String id) {
    return Caregiver(
      id: id,
      name: map['name'] ?? '',
      employeeID: map['employeeID'] ?? 'CG0000',
      isAvailable: map['isAvailable'] ?? false,
      startExperience: map['startExperience'] != null
          ? (map['startExperience'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'employeeID': employeeID,
      'isAvailable': isAvailable,
      if (startExperience != null) 'startExperience': Timestamp.fromDate(startExperience!),
    };
  }
}