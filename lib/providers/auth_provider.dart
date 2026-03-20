import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum LoginMode { none, user, admin }

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  UserModel? _userModel;
  AdminModel? _adminModel;
  String _role = '';
  bool _isLoading = true;
  String? _error;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  AdminModel? get adminModel => _adminModel;
  String get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _role.isNotEmpty;
  bool get isAdmin => _role == 'admin';

  AppAuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Listen to auth state but don't auto-determine role
    // The user must choose their login mode explicitly
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        _currentUser = null;
        _userModel = null;
        _adminModel = null;
        _role = '';
        _isLoading = false;
        notifyListeners();
      } else if (_role.isEmpty) {
        // User is signed in from a previous session — try to restore role
        _currentUser = user;
        await _restoreRole(user);
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Restore role on app restart from persisted auth state
  Future<void> _restoreRole(User user) async {
    try {
      // Check admins collection first
      final admin =
          await _firestoreService.getAdminByEmail(user.email ?? '');
      if (admin != null) {
        _adminModel = admin;
        _role = 'admin';
        return;
      }

      // Check users collection
      final existingUser = await _firestoreService.getUserDoc(user.uid);
      if (existingUser != null) {
        _userModel = existingUser;
        _role = 'user';
      }
      // If neither found, role stays empty → will show login screen
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Sign in as User — Google sign-in → create/fetch from users collection
  Future<bool> signInAsUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;

      // Check if user doc exists
      UserModel? existingUser =
          await _firestoreService.getUserDoc(user.uid);
      if (existingUser != null) {
        _userModel = existingUser;
      } else {
        // First-time login — create user doc
        await _firestoreService.createUserDoc(
          user.uid,
          user.displayName ?? 'User',
          user.email ?? '',
        );
        _userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          role: 'user',
        );
      }
      _role = 'user';

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in as Admin — Google sign-in → verify email in admins collection
  Future<bool> signInAsAdmin() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;

      // Check admins collection by email
      final admin =
          await _firestoreService.getAdminByEmail(user.email ?? '');
      if (admin != null) {
        _adminModel = admin;
        _role = 'admin';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Not an admin — sign out and show error
        _error =
            'No admin account found for ${user.email}. Contact your administrator.';
        await _authService.signOut();
        _currentUser = null;
        _role = '';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _userModel = null;
      _adminModel = null;
      _role = '';
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    try {
      if (_role == 'admin' && _adminModel != null) {
        await _firestoreService.updateAdminName(_adminModel!.docId, name);
        _adminModel = AdminModel(
          docId: _adminModel!.docId,
          adminID: _adminModel!.adminID,
          name: name,
          email: _adminModel!.email,
          department: _adminModel!.department,
          createdAt: _adminModel!.createdAt,
        );
      } else if (_userModel != null) {
        await _firestoreService.updateUserName(_currentUser!.uid, name);
        _userModel = _userModel!.copyWith(name: name);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
