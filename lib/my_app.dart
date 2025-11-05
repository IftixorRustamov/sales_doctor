import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_doctor/bloc/location_bloc.dart';
import 'package:sales_doctor/data/database_helper.dart';
import 'package:sales_doctor/data/firebase_service.dart';
import 'package:sales_doctor/data/location_repository.dart';

import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocProvider(
        create: (context) => LocationBloc(
          locationRepository: LocationRepository(
            databaseHelper: DatabaseHelper.instance,
            firebaseService: FirebaseService(),
          ),
        ),
        child: const HomeScreen(),
      ),
    );
  }
}
