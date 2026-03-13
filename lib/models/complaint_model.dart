import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String adminId;
  final String imageUrl;
  final String status;
  final Timestamp createdAt;
  final String userId;
  final String userName;
  final String resolutionNote;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.adminId,
    this.imageUrl = '',
    this.status = 'Pending',
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.resolutionNote = '',
  });

  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      adminId: data['adminId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      resolutionNote: data['resolutionNote'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'adminId': adminId,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt,
      'userId': userId,
      'userName': userName,
      'resolutionNote': resolutionNote,
    };
  }
}
