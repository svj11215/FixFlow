import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '704590445192-v6u1ps29du45hi81bbaq1up306hb7fmg.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Use Firebase Auth's GoogleAuthProvider on web to bypass the
        // google_sign_in_web package's inherent People API dependency.
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        
        // Force account picker on web
        authProvider.setCustomParameters({
          'prompt': 'select_account'
        });
        
        final userCredential = await _auth.signInWithPopup(authProvider);
        return userCredential.user;
      } else {
        // Fallback for native platforms
        
        // Sign out of any cached Google session first to force account picker
        await _googleSignIn.signOut();
        
        // Now sign in fresh
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
