import 'package:homecare0x1/models/caregiver.dart';

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
