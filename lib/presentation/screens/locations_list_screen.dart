import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_doctor/presentation/widgets/location_card.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class LocationsListScreen extends StatefulWidget {
  const LocationsListScreen({super.key});

  @override
  State<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends State<LocationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(LoadLocations());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LocationBloc>().add(LoadLocations());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          switch (state.loadingStatus) {
            case LocationLoadingStatus.loading:
              return _buildLoadingState();
            case LocationLoadingStatus.error:
              return _buildErrorState(context, state.errorMessage);
            case LocationLoadingStatus.loaded:
            case LocationLoadingStatus.initial:
              return state.locations.isEmpty
                  ? _buildEmptyState()
                  : _buildLoadedState(state);
          }
        },
      ),
    );
  }

  // --- Extracted State Builders ---

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading locations...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Error loading locations',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LocationBloc>().add(LoadLocations());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No locations saved yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking and wait for the 20-second sync.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(LocationState state) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Text(
            'Total Locations: ${state.locations.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.locations.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final location = state.locations[index];
              return LocationCard(location: location, index: index);
            },
          ),
        ),
      ],
    );
  }
}
