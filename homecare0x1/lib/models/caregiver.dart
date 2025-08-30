// Caregiver model to represent caregiver data from Firestore
class Caregiver {
  final String id; // Unique identifier for the caregiver
  final String name; // Name of the caregiver
  final bool isAvailable; // Availability status of the caregiver
  final DateTime? startExperience; // Start date of experience (optional)

  Caregiver({
    required this.id,
    required this.name,
    required this.isAvailable,
    this.startExperience,
  });

  // Factory method to create a Caregiver object from Firestore document data
  factory Caregiver.fromMap(Map<String, dynamic> map, String id) {
    return Caregiver(
      id: id,
      name: map['name'],
      isAvailable: map['isAvailable'],
    );
  }
}
