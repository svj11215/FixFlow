import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcY-rhSymWE5d5Cz2geNUTZ-VLMk8a8N4',
    appId: '1:704590445192:web:cc985bd0e5e5a67bc07d3d',
    messagingSenderId: '704590445192',
    projectId: 'fixflow-dc246',
    authDomain: 'fixflow-dc246.firebaseapp.com',
    storageBucket: 'fixflow-dc246.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcY-rhSymWE5d5Cz2geNUTZ-VLMk8a8N4',
    appId: '1:704590445192:android:cc985bd0e5e5a67bc07d3d',
    messagingSenderId: '704590445192',
    projectId: 'fixflow-dc246',
    storageBucket: 'fixflow-dc246.firebasestorage.app',
  );
}
