import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverProfile {
  final String id;
  final String name;
  final String employeeID;
  final String position;
  final DateTime dateOfBirth;
  final String address;
  final String role;
  final String experience;
  final List<String> certifications;
  final String phone;
  final String email;
  final String bio;
  final List<String> availability;
  final double rating;
  final int reviews;
  final bool approved;
  final String? approverId;

  CaregiverProfile({
    required this.id,
    required this.name,
    required this.employeeID,
    required this.position,
    required this.dateOfBirth,
    required this.address,
    required this.role,
    required this.experience,
    required this.certifications,
    required this.phone,
    required this.email,
    required this.bio,
    required this.availability,
    required this.rating,
    required this.reviews,
    this.approved = false,
    this.approverId,
  });

  factory CaregiverProfile.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverProfile(
      id: id,
      name: map['name'] ?? '',
      employeeID: map['employeeID'] ?? 'CG0000',
      position: map['position'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
          : DateTime(1980),
      address: map['address'] ?? '',
      role: map['role'] ?? '',
      experience: map['experience'] ?? '',
      certifications: List<String>.from(map['certifications'] ?? []),
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      availability: List<String>.from(map['availability'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (map['reviews'] as num?)?.toInt() ?? 0,
      approved: map['approved'] ?? false,
      approverId: map['approverId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'employeeID': employeeID,
      'position': position,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'address': address,
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
    };
  }
}