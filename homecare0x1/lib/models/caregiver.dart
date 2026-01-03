// Caregiver model to represent caregiver data from Firestore
class Caregiver {
  final String id; // Unique identifier for the caregiver
  final String name; // Name of the caregiver
  final bool isAvailable; // Availability status of the caregiver
  final double hourlyRate; // Hourly rate for cost calculation
  final DateTime? startExperience; // Start date of experience (optional)

  Caregiver({
    required this.id,
    required this.name,
    required this.isAvailable,
    this.hourlyRate = 0.0,
    this.startExperience,
  });

  // Factory method to create a Caregiver object from Firestore document data
  factory Caregiver.fromMap(Map<String, dynamic> map, String id) {
    DateTime? experienceDate;
    if (map['startExperience'] != null) {
      try {
        experienceDate = DateTime.parse(map['startExperience']);
      } catch (e) {
        print('Error parsing startExperience date: $e');
        experienceDate = null; // Fallback to null on parse failure
      }
    }

    return Caregiver(
      id: id,
      name: map['name'] ?? '', // Default to empty string if null
      isAvailable: map['isAvailable'] ?? false, // Default to false if null
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      startExperience: experienceDate,
    );
  }

  // Converts the Caregiver object to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isAvailable': isAvailable,
      'hourlyRate': hourlyRate,
      'startExperience': startExperience?.toIso8601String(), // Serialize DateTime to ISO string
    };
  }
}
