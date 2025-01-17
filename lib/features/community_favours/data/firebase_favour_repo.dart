import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/favour.dart';
import '../domain/repos/favour_repo.dart';

class FirebaseFavourRepo implements FavourRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Store the favours in a collection called favours.
  final CollectionReference favourCollection =
      FirebaseFirestore.instance.collection('Favours');

  @override
  Future<void> createFavour(Favour favour) async {
    // Create a new favour in the favours collection.
    try {
      await favourCollection.doc(favour.id).set(favour.toJson());
    } catch (e) {
      throw Exception('Error creating favour: $e');
    }
  }

  @override
  Future<void> deleteFavour(String favourId) async {
    // Delete favour in firebase.
    try {
      await favourCollection.doc(favourId).delete();
    } catch (e) {
      throw Exception('Error deleting favour: $e');
    }
  }

  @override
  Future<List<Favour>> fetchAllFavours() async {
    try {
      // Get all the favours from the firestore with the most recent on the top.
      final favoursSnapshot = await favourCollection
          .orderBy('scheduledTime', descending: true)
          .get();

      // Convert each firestore document from JSON --> List of favours.
      final List<Favour> allFavours = favoursSnapshot.docs
          .map((doc) => Favour.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allFavours;
    } catch (e) {
      throw Exception('Error fetching the favours: $e');
    }
  }

  @override
  Future<List<Favour>> fetchFavourByUserID(String userId) async {
    try {
      // Fetch favours using userID.
      final favourSnapshot =
          await favourCollection.where('userId', isEqualTo: userId).get();

      // Convert the favours from JSON --> List of favours.
      final List<Favour> userFavours = favourSnapshot.docs
          .map((doc) => Favour.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userFavours;
    } catch (e) {
      throw Exception('Error fetching favours by user: $e');
    }
  }
}
