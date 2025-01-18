import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:huddle/app.dart';
import 'package:huddle/common/config/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //flutter setup
  WidgetsFlutterBinding.ensureInitialized();
  //Mobile ads setup
  MobileAds.instance.initialize();
  //Cache setup
  await SharedPreferences.getInstance();
  //firebase setup
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}
//Naman Goyal
