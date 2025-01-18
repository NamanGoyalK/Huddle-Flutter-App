import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:huddle/common/config/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:huddle/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    MobileAds.instance.initialize();
    await SharedPreferences.getInstance();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (kDebugMode) {
      print("Firebase initialization error: $e");
    }
  }
}
