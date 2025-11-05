import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/database_helper.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await DatabaseHelper.instance.initializeDatabases();

  runApp(const MyApp());
}
