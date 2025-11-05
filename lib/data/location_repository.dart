import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import 'database_helper.dart';
import 'firebase_service.dart';

class BackgroundServiceHandler {
  Timer? _timer10s;
  Timer? _timer20s;
  final LocationRepository repository;

  BackgroundServiceHandler(this.repository);

  void start() {
    print('MOCK: Starting 10-second and 20-second timers.');

    _timer10s = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await repository.handle10SecondSave();
    });

    _timer20s = Timer.periodic(const Duration(seconds: 20), (timer) async {
      await repository.handle20SecondSync();
    });
  }

  void stop() {
    print('MOCK: Cancelling timers.');
    _timer10s?.cancel();
    _timer20s?.cancel();
    _timer10s = null;
    _timer20s = null;
  }
}
// -------------------------------------------------------------------------

class LocationRepository {
  final DatabaseHelper databaseHelper;
  final FirebaseService firebaseService;

  // ⚠️ CRITICAL: Using the MOCK handler. This MUST be replaced with a real service
  // to achieve tracking when the app is closed.
  late final BackgroundServiceHandler _serviceHandler;

  LocationRepository({
    required this.databaseHelper,
    required this.firebaseService,
  }) {
    _serviceHandler = BackgroundServiceHandler(this);
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

  // --- Start/Stop: Now control the background service handler ---

  void startTracking(Function(String) onError) {
    _serviceHandler.start();
  }

  void stopTracking() {
    _serviceHandler.stop();
  }

  void dispose() {
    _serviceHandler.stop();
  }


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
      print(
        '[WORKER 10s] Saved to DB1: ${location.latitude.toStringAsFixed(4)}',
      );
    } catch (e) {
      print('Error in 10s worker: $e');
    }
  }

  // 2. 20-Second Worker: Full Sync Transaction (DB1 -> DB2 -> Firebase)
  Future<void> handle20SecondSync() async {
    print('[WORKER 20s] Starting data sync process.');

    final locationsFromDB1 = await databaseHelper.getAllFromDatabase1();

    if (locationsFromDB1.isEmpty) {
      print('[WORKER 20s] DB1 empty. Skipping transfer/sync.');
      return;
    }

    // --- A. Transfer DB1 to Database 2 and Clear DB1 ---
    try {
      for (var location in locationsFromDB1) {
        await databaseHelper.insertToDatabase2(location);
      }
      await databaseHelper.clearDatabase1(); // ✅ FIX: Clears DB1
      print(
        '[WORKER 20s] Transferred ${locationsFromDB1.length} locations to DB2.',
      );
    } catch (e) {
      print('Error transferring DB1 to DB2: $e');
      return; // Stop sync if the local transfer fails
    }

    // --- B. Sync Database 2 to Firebase and Clear DB2 ---
    await _syncDatabase2ToServer();
  }

  Future<void> _syncDatabase2ToServer() async {
    final locationsToSync = await databaseHelper.getAllFromDatabase2();

    if (locationsToSync.isEmpty) {
      print('[WORKER Sync] DB2 is empty. Nothing to sync.');
      return;
    }

    try {
      // Use the efficient bulk save
      await firebaseService.saveLocations(locationsToSync);

      // ONLY clear DB2 if the sync was successful
      await databaseHelper.clearDatabase2(); // ✅ FIX: Clears DB2
      print(
        '[WORKER Sync] Successfully synced ${locationsToSync.length} locations to Firebase.',
      );
    } catch (e) {
      print(
        '[WORKER Sync] Failed to sync to Firebase. Data remains in DB2. Error: $e',
      );
    }
  }

  // --- UI/BLoC Data Fetching ---

  Future<List<LocationModel>> getLocationsFromFirebase() async {
    return await firebaseService.getAllLocations();
  }
}
