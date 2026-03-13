import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "user" or "admin"
  final String adminId; // empty for regular users

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.adminId = '',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      adminId: data['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'adminId': adminId,
    };
  }

  UserModel copyWith({String? name, String? email, String? role, String? adminId}) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      adminId: adminId ?? this.adminId,
    );
  }
}

class AdminModel {
  final String docId;
  final int adminID;
  final String name;
  final String email;
  final String department;
  final Timestamp? createdAt;

  AdminModel({
    required this.docId,
    required this.adminID,
    required this.name,
    required this.email,
    this.department = '',
    this.createdAt,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      docId: doc.id,
      adminID: data['adminID'] ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  String get adminIdString => adminID.toString().padLeft(6, '0');
}
