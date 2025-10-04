

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
  final String foodAndDrinks; // Added for food and drinks description
  final int mealQuantityPercentage; // Added for caregiver's evaluation of eating quantity
  final int hydrationMl; // Added for hydration tracking in ml
  final bool hasBowelMovement; // Added for bowel movement yes/no
  final String? bowelMovementDescription; // Added for bowel movement description (nullable)
  final int bowelMovementFrequency; // Added to track frequency for alert functionality
  final String mobilityAndShower; // Added for mobility and shower description

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
    required this.foodAndDrinks,
    required this.mealQuantityPercentage,
    required this.hydrationMl,
    required this.hasBowelMovement,
    this.bowelMovementDescription,
    this.bowelMovementFrequency = 0,
    required this.mobilityAndShower,
  }) : id = id ?? const Uuid().v4();

  // Method to check if admin should be alerted for no bowel movement in 3 days
  bool shouldAlertAdminForBowelMovement() {
    return hasBowelMovement == false && bowelMovementFrequency >= 3;
  }
}



// import 'package:uuid/uuid.dart';

// class CareNote {
//   final String id;
//   final String clientId;
//   final String caregiverId;
//   final String shiftId;
//   final String healthStatus;
//   final String activities;
//   final String observations;
//   final String medicationAdherence;
//   final String mood;
//   final String note;
//   final DateTime timestamp;
//   final bool isVisibleToClient;
//   final bool isLate;

//   CareNote({
//     String? id,
//     required this.clientId,
//     required this.caregiverId,
//     required this.shiftId,
//     required this.healthStatus,
//     required this.activities,
//     required this.observations,
//     required this.medicationAdherence,
//     required this.mood,
//     required this.note,
//     required this.timestamp,
//     this.isVisibleToClient = false,
//     this.isLate = false,
//   }) : id = id ?? const Uuid().v4();
// }

