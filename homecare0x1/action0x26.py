import os

def fix_model_syntax_errors():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Fix lib/models/caregiver.dart (Overwrite with correct code)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/models/caregiver.dart ---")
    caregiver_path = os.path.join("lib", "models", "caregiver.dart")
    
    caregiver_code = """// Caregiver model to represent caregiver data from Firestore
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
"""
    with open(caregiver_path, "w", encoding="utf-8") as f:
        f.write(caregiver_code)
    print("Fixed syntax errors in caregiver.dart.")

    # ---------------------------------------------------------
    # 2. Fix lib/models/caregiver_profile.dart (Safety Check)
    # ---------------------------------------------------------
    print("\n--- Ensuring lib/models/caregiver_profile.dart is correct ---")
    profile_path = os.path.join("lib", "models", "caregiver_profile.dart")
    
    if os.path.exists(profile_path):
        # We overwrite this too to be absolutely sure no bad regex touched it
        profile_code = """import 'package:homecare0x1/models/caregiver.dart';

class CaregiverProfile {
  final String id;
  final String name;
  final String role;
  final String? experience;
  final List<String>? certifications;
  final String? phone;
  final String? email;
  final String? bio;
  final List<String>? availability;
  final double rating;
  final int reviews;
  final bool approved;
  final String? approverId;
  final double hourlyRate;

  CaregiverProfile({
    required this.id,
    required this.name,
    required this.role,
    this.experience,
    this.certifications,
    this.phone,
    this.email,
    this.bio,
    this.availability,
    required this.rating,
    required this.reviews,
    required this.approved,
    this.approverId,
    this.hourlyRate = 0.0,
  });

  factory CaregiverProfile.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverProfile(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? 'Caregiver',
      experience: map['experience'],
      certifications: List<String>.from(map['certifications'] ?? []),
      phone: map['phone'],
      email: map['email'],
      bio: map['bio'],
      availability: List<String>.from(map['availability'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
      approved: map['approved'] ?? false,
      approverId: map['approverId'],
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'experience': experience,
      'certifications': certifications,
      'phone': phone,
      'email': email,
      'bio': bio,
      'availability': availability,
      'rating': rating,
      'reviews': reviews,
      'approved': approved,
      'approverId': approverId,
      'hourlyRate': hourlyRate,
    };
  }
}
"""
        with open(profile_path, "w", encoding="utf-8") as f:
            f.write(profile_code)
        print("Ensured caregiver_profile.dart is clean and correct.")

if __name__ == "__main__":
    fix_model_syntax_errors()