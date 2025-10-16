import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';

class CaregiverProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _caregiverProfilesCollection = 'caregiver_profiles';
  List<CaregiverProfile> _caregivers = [];

  List<CaregiverProfile> get caregivers => _caregivers;

  Future<String> _generateEmployeeID() async {
    if (_caregivers.isEmpty) {
      await fetchCaregivers();
    }
    if (_caregivers.isEmpty) {
      return 'CG0001';
    }

    final numbers = _caregivers.map((caregiver) {
      final match = RegExp(r'CG(\d+)').firstMatch(caregiver.employeeID);
      return match != null ? int.parse(match.group(1)!) : 0;
    }).toList();

    final maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    final nextNumber = maxNumber + 1;
    return 'CG${nextNumber.toString().padLeft(4, '0')}';
  }

  Future<void> addCaregiver({
    required String name,
    required String position,
    required DateTime dateOfBirth,
    required String address,
    String email = '',
    String phone = '',
    String bio = '',
    String role = 'Caregiver',
    String experience = '',
    List<String> certifications = const [],
    List<String> availability = const [],
    double rating = 0.0,
    int reviews = 0,
  }) async {
    try {
      final String employeeID = await _generateEmployeeID();
      final String docId = DateTime.now().millisecondsSinceEpoch.toString();

      final CaregiverProfile newCaregiver = CaregiverProfile(
        id: docId,
        name: name,
        employeeID: employeeID,
        position: position,
        dateOfBirth: dateOfBirth,
        address: address,
        role: role,
        experience: experience,
        certifications: certifications,
        phone: phone,
        email: email,
        bio: bio,
        availability: availability,
        rating: rating,
        reviews: reviews,
        approved: false,
        approverId: null,
      );

      await _firestore.collection(_caregiverProfilesCollection).doc(docId).set(newCaregiver.toMap());
      _caregivers.add(newCaregiver);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to add caregiver: $error');
    }
  }

  Future<void> fetchCaregivers() async {
    try {
      final querySnapshot = await _firestore.collection(_caregiverProfilesCollection).get();
      _caregivers = querySnapshot.docs
          .map((doc) => CaregiverProfile.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to fetch caregivers: $error');
    }
  }

  Future<void> updateCaregiver(CaregiverProfile updatedCaregiver) async {
    try {
      await _firestore.collection(_caregiverProfilesCollection).doc(updatedCaregiver.id).set(updatedCaregiver.toMap());
      final index = _caregivers.indexWhere((caregiver) => caregiver.id == updatedCaregiver.id);
      if (index != -1) {
        _caregivers[index] = updatedCaregiver;
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Failed to update caregiver: $error');
    }
  }

  Future<void> deleteCaregiver(String caregiverId) async {
    try {
      await _firestore.collection(_caregiverProfilesCollection).doc(caregiverId).delete();
      _caregivers.removeWhere((caregiver) => caregiver.id == caregiverId);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to delete caregiver: $error');
    }
  }
}