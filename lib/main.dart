import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/database_helper.dart';
import 'my_app.dart';
import 'service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDependencies();
  await sl<DatabaseHelper>().initializeDatabases();
  runApp(const MyApp());
}
