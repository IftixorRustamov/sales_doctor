import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/location_model.dart';
import '../utils/app_logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionPath = 'user_locations';

  Future<void> saveLocations(List<LocationModel> locations) async {
    if (locations.isEmpty) return;

    final batch = _firestore.batch();
    final collection = _firestore.collection(collectionPath);

    for (var location in locations) {
      final docRef = collection.doc(); // Generate a new ID for each location
      batch.set(docRef, location.toFirestore());
    }

    try {
      await batch.commit();
      appLogger.i(
        'Successfully committed batch of ${locations.length} locations to Firebase.',
      );
    } on FirebaseException catch (e) {
      appLogger.e('Firebase Batch Save Error: $e');
      rethrow;
    } catch (e) {
      appLogger.e('General Firebase Save Error: $e');
      rethrow;
    }
  }

  Future<List<LocationModel>> getAllLocations() async {
    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .orderBy('timestamp', descending: true)
          .get();

      appLogger.i('Fetched ${snapshot.docs.length} locations from Firebase.');
      return snapshot.docs
          .map((doc) => LocationModel.fromFirestore(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      appLogger.e('Firebase Fetch Error: $e');
      return [];
    }
  }
}
