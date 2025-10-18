// New file: lib/services/firebase_caregiver_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/caregiver.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/services/auditlog_service.dart';

class FirebaseCaregiverService {
  static final FirebaseCaregiverService instance =
      FirebaseCaregiverService._constructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _caregiversCollection = 'caregivers';
  final String _caregiverProfilesCollection = 'caregiver_profiles';
  final FirebaseAuditLogService _auditLogService =
      FirebaseAuditLogService.instance;

  FirebaseCaregiverService._constructor();

  Future<CaregiverProfile?> getCaregiverProfile(String caregiverId) async {
    try {
      final doc = await _firestore
          .collection(_caregiverProfilesCollection)
          .doc(caregiverId)
          .get();
      if (doc.exists) {
        return CaregiverProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching caregiverProfile profile: $e');
      return null;
    }
  }

  Future<List<CaregiverProfile>> getUnApprovedCaregivers() async {
    try {
      final snapshot = await _firestore
          .collection(_caregiverProfilesCollection)
          .where('approved', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => CaregiverProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching unapproved caregivers: $e');
      return [];
    }
  }

  Future<List<CaregiverProfile>> getCaregiversForClient(
      List<String> caregiverIds) async {
    try {
      final profiles = <CaregiverProfile>[];
      for (var caregiverId in caregiverIds) {
        final profile = await getCaregiverProfile(caregiverId);
        if (profile != null) {
          profiles.add(profile);
        }
      }
      return profiles;
    } catch (e) {
      print('Error fetching caregivers for client: $e');
      return [];
    }
  }

  Future<String> upsertCaregiverProfile(CaregiverProfile profile) async {
    try {
      await _firestore
          .collection(_caregiverProfilesCollection)
          .doc(profile.id)
          .set(profile.toMap());
      // Create audit log entry for profile update
      await _auditLogService.createAuditLog(
        userId: profile.approverId ?? 'system',
        userName: profile.approverId != null ? 'approver' : 'system',
        userRole: 'caregiverProfile',
        action: 'Updated caregiverProfile profile for ${profile.name}',
        actionType: 'data change',
        severity: 'info',
        details: 'Caregiver ID: ${profile.id}, Approved: ${profile.approved}',
      );
      return "success";
    } catch (e) {
      print('Error upserting caregiverProfile profile: $e');
      return "error";
    }
  }

  Future<String> upsertApprovalStatus(
      String caregiverId, bool approved, String? approverId) async {
    if (approverId == null && approved) {
      return "error";
    }
    try {
      await _firestore
          .collection(_caregiverProfilesCollection)
          .doc(caregiverId)
          .update({
        'approved': approved,
        'approverId': approverId,
      });
      return "success";
    } catch (e) {
      print('Error updating approval status: $e');
      return "error";
    }
  }

  Future<List<Caregiver>> getAvailableCaregivers() async {
    try {
      final snapshot = await _firestore.collection(_caregiversCollection).get();
      return snapshot.docs
          .map((doc) => Caregiver.fromMap(doc.data(), doc.id))
          .where((cg) => cg.isAvailable)
          .toList();
    } catch (e) {
      print('Error fetching available caregivers: $e');
      return [];
    }
  }

  Future<List<CaregiverProfile>> getAllCaregiverProfiles() async {
    try {
      final snapshot =
          await _firestore.collection(_caregiverProfilesCollection).get();
      return snapshot.docs
          .map((doc) => CaregiverProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all caregiverProfile profiles: $e');
      return [];
    }
  }

// Updated method in FirebaseCaregiverService class
  Future<String> createCaregiver(CaregiverProfile profile) async {
    try {
      // Use a batch for atomicity (both writes succeed or fail together)
      final batch = _firestore.batch();

      // Step 1: Map to minimal Caregiver for 'caregivers' collection
      final caregiver = Caregiver(
        id: '', // ID will be assigned post-add (via doc reference)
        name: profile.name,
        isAvailable:
            false, // Default to available for new caregivers; can be overridden
        startExperience: DateTime.tryParse(
            profile.experience ?? ''), // Attempt to parse experience as date
      );

      // Prepare reference for 'caregivers' (auto-generate ID)
      final caregiverRef = _firestore.collection(_caregiversCollection).doc();
      batch.set(caregiverRef, caregiver.toMap());

      // Step 2: Create full profile in 'caregiver_profiles' using the same ID
      final fullProfile = CaregiverProfile(
        id: caregiverRef.id,
        name: profile.name,
        role: profile.role,
        experience: profile.experience ?? '', // Ensure non-null
        certifications:
            profile.certifications ?? [], // Ensure list is initialized
        phone: profile.phone ?? '',
        email: profile.email ?? '',
        bio: profile.bio ?? '',
        availability: profile.availability ?? [],
        rating: profile.rating,
        reviews: profile.reviews,
        approved: profile.approved,
        approverId: profile.approverId,
      );
      batch.set(
        _firestore
            .collection(_caregiverProfilesCollection)
            .doc(caregiverRef.id),
        fullProfile.toMap(),
      );

      // Commit the batch
      await batch.commit();

      // Step 3: Enhanced audit log with full details
      await _auditLogService.createAuditLog(
        userId: caregiverRef.id,
        userName: profile.name ?? 'Unknown',
        userRole: 'caregiver',
        action: 'Created new caregiver entry for ${profile.name}',
        actionType: 'adding caregiver',
        severity: 'info',
        details:
            'Caregiver ID: ${caregiverRef.id}, Name: ${profile.name}, Profile Created: true, Available: true',
      );

      return caregiverRef.id;
    } catch (e) {
      print('Error creating caregiver: $e');
      return 'Error: $e';
    }
  }
}
