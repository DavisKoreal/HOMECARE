// New file: lib/services/firebase_caregiver_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/caregiver.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/services/auditlog_service.dart';

class FirebaseCaregiverService {
  static final FirebaseCaregiverService instance = FirebaseCaregiverService._constructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _caregiversCollection = 'caregivers';
  final String _caregiverProfilesCollection = 'caregiver_profiles';
  final FirebaseAuditLogService _auditLogService = FirebaseAuditLogService.instance;

  FirebaseCaregiverService._constructor();

  Future<CaregiverProfile?> getCaregiverProfile(String caregiverId) async {
    try {
      final doc = await _firestore.collection(_caregiverProfilesCollection).doc(caregiverId).get();
      if (doc.exists) {
        return CaregiverProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching caregiver profile: $e');
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

  Future<List<CaregiverProfile>> getCaregiversForClient(List<String> caregiverIds) async {
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
      await _firestore.collection(_caregiverProfilesCollection).doc(profile.id).set(profile.toMap());
      // Create audit log entry for profile update
      await _auditLogService.createAuditLog(
        userId: profile.approverId ?? 'system',
        userName: profile.approverId != null ? 'approver' : 'system',
        userRole: 'caregiver',
        action: 'Updated caregiver profile for ${profile.name}',     
        actionType: 'data change',
        severity: 'info',
        details: 'Caregiver ID: ${profile.id}, Approved: ${profile.approved}',
      );
      return "success";
    } catch (e) {
      print('Error upserting caregiver profile: $e');
      return "error";
    }
  }

  Future<String> upsertApprovalStatus(String caregiverId, bool approved, String? approverId) async {
    if (approverId == null && approved) {
      return "error";
    }
    try {
      await _firestore.collection(_caregiverProfilesCollection).doc(caregiverId).update({
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
      final snapshot = await _firestore.collection(_caregiverProfilesCollection).get();
      return snapshot.docs
          .map((doc) => CaregiverProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all caregiver profiles: $e');
      return [];
    }
  }
}