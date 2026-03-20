import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/image_upload_provider.dart';

/// Safely handles Firebase Auth photo URLs, converting http to https
/// and handling null/empty values to prevent broken image icons on Flutter Web.
String? safePhotoUrl(User? user) {
  if (user == null) return null;
  final url = user.photoURL;
  if (url == null || url.isEmpty) return null;
  // Force https to avoid mixed content on web
  return url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const FixFlowApp(),
    ),
  );
}