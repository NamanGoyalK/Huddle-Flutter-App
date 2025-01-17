import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:huddle/app.dart';
import 'package:huddle/common/config/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteOldPosts() async {
  final firestore = FirebaseFirestore.instance;

  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(Duration(days: 7));
  final oldPosts = await firestore
      .collection('posts')
      .where('timestamp', isLessThan: sevenDaysAgo)
      .get();

  for (var doc in oldPosts.docs) {
    await doc.reference.delete();
  }

  print('Deleted ${oldPosts.size} old posts');
}

void main() async {
  // Flutter setup
  WidgetsFlutterBinding.ensureInitialized();

  // Cache setup
  await SharedPreferences.getInstance();

  // Firebase setup
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run cleanup for old posts
  await deleteOldPosts();

  runApp(MyApp());
}
