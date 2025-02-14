import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:huddle/app.dart';

import 'core/config/notifications/firebase_notifications.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await SharedPreferences.getInstance();
  await _initializeFirebase();
  await FirebaseNotifications().initNotifications();
  runApp(MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (kDebugMode) {
      print("Firebase initialization error: $e");
    }
  }
}
