import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/firestore_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> submitComplaint({
    required String title,
    required String description,
    required String category,
    required String location,
    required String adminId,
    required String userId,
    required String userName,
    String imageUrl = '',
  }) async {
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();

      final complaint = ComplaintModel(
        id: '',
        title: title,
        description: description,
        category: category,
        location: location,
        adminId: adminId,
        imageUrl: imageUrl,
        status: 'Pending',
        createdAt: Timestamp.now(),
        userId: userId,
        userName: userName,
      );

      await _firestoreService.submitComplaint(complaint);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComplaint(String complaintId) async {
    try {
      await _firestoreService.deleteComplaint(complaintId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComplaint(
      String complaintId, String status, String resolutionNote) async {
    try {
      await _firestoreService.updateComplaintStatus(
          complaintId, status, resolutionNote);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<ComplaintModel>> userComplaints(String userId) {
    return _firestoreService.streamUserComplaints(userId);
  }

  Stream<List<ComplaintModel>> adminComplaints(String adminId) {
    return _firestoreService.streamAdminComplaints(adminId);
  }
}
