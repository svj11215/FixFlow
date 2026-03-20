import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Operations ───────────────────────────────────────

  Future<void> createUserDoc(String uid, String name, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'user',
        'adminId': '',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserDoc(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserName(String uid, String name) async {
    try {
      await _db.collection('users').doc(uid).update({'name': name});
    } catch (e) {
      rethrow;
    }
  }

  // ─── Admin Operations ──────────────────────────────────────

  Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return AdminModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAdminName(String docId, String name) async {
    try {
      await _db.collection('admins').doc(docId).update({'name': name});
    } catch (e) {
      rethrow;
    }
  }

  // ─── Complaint Operations ──────────────────────────────────

  Future<void> submitComplaint(ComplaintModel complaint) async {
    try {
      await _db.collection('complaints').add(complaint.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ComplaintModel>> streamUserComplaints(String userId) {
    return _db
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ComplaintModel>> streamAdminComplaints(String adminId) {
    return _db
        .collection('complaints')
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: false)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateComplaintStatus(
      String complaintId, String status, String resolutionNote) async {
    try {
      await _db.collection('complaints').doc(complaintId).update({
        'status': status,
        'resolutionNote': resolutionNote,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _db.collection('complaints').doc(complaintId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
