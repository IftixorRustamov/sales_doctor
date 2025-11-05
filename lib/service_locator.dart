import 'package:get_it/get_it.dart';
import 'package:sales_doctor/data/database_helper.dart';
import 'package:sales_doctor/data/firebase_service.dart';
import 'package:sales_doctor/data/location_repository.dart';

import 'utils/app_logger.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  appLogger.i('Initializing Dependency Injection...');

  sl.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepository(databaseHelper: sl(), firebaseService: sl()),
  );

  appLogger.i('Dependency Injection setup complete.');
}
