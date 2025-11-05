import 'dart:async';

import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../utils/app_logger.dart';
import 'database_helper.dart';
import 'firebase_service.dart';
import 'services/background_service_handler.dart';

class LocationRepository implements BackgroundSyncExecutor {
  final DatabaseHelper databaseHelper;
  final FirebaseService firebaseService;

  late final BackgroundServiceHandler _serviceHandler;

  LocationRepository({
    required this.databaseHelper,
    required this.firebaseService,
  }) {
    _serviceHandler = BackgroundServiceHandler(executor: this);
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void startTracking() {
    _serviceHandler.start();
  }

  void stopTracking() {
    _serviceHandler.stop();
  }

  void dispose() {
    _serviceHandler.stop();
  }

  Future<List<LocationModel>> getLocationsFromFirebase() async {
    return await firebaseService.getAllLocations();
  }

  @override
  Future<void> handle10SecondSave() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().toIso8601String(),
      );

      await databaseHelper.insertToDatabase1(location);
      appLogger.d(
        '[WORKER 10s] Saved to DB1: ${location.latitude.toStringAsFixed(4)}',
      );
    } on TimeoutException {
      appLogger.e('10s worker failed: Geolocator timeout.');
    } catch (e) {
      appLogger.e('Error in 10s worker: $e');
    }
  }

  @override
  Future<void> handle20SecondSync() async {
    appLogger.d('[WORKER 20s] Starting data sync process.');

    final locationsFromDB1 = await databaseHelper.getAllFromDatabase1();

    if (locationsFromDB1.isEmpty) {
      appLogger.d('[WORKER 20s] DB1 empty. Skipping transfer/sync.');
      return;
    }

    try {
      for (var location in locationsFromDB1) {
        await databaseHelper.insertToDatabase2(location);
      }
      await databaseHelper.clearDatabase1();
      appLogger.i(
        '[WORKER 20s] Transferred ${locationsFromDB1.length} locations to DB2.',
      );
    } catch (e) {
      appLogger.e('Error transferring DB1 to DB2: $e');
      return;
    }

    await _syncDatabase2ToServer();
  }

  Future<void> _syncDatabase2ToServer() async {
    final locationsToSync = await databaseHelper.getAllFromDatabase2();

    if (locationsToSync.isEmpty) {
      appLogger.d('[WORKER Sync] DB2 is empty. Nothing to sync.');
      return;
    }

    try {
      await firebaseService.saveLocations(locationsToSync);

      // await databaseHelper.clearDatabase2();
      appLogger.i(
        '[WORKER Sync] Successfully synced ${locationsToSync.length} locations to Firebase.',
      );
    } catch (e) {
      appLogger.e(
        '[WORKER Sync] Failed to sync to Firebase. Data remains in DB2. Error: $e',
      );
    }
  }
}
