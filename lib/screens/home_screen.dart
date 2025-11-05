import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import 'locations_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Tracker'), elevation: 2),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        state.trackingStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(state.trackingStatus),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(state.trackingStatus),
                          color: _getStatusColor(state.trackingStatus),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getStatusText(state.trackingStatus),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(state.trackingStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: state.trackingStatus == TrackingStatus.tracking
                          ? null
                          : () {
                              context.read<LocationBloc>().add(StartTracking());
                            },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'START',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stop Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: state.trackingStatus == TrackingStatus.tracking
                          ? () {
                              context.read<LocationBloc>().add(StopTracking());
                            }
                          : null,
                      icon: const Icon(Icons.stop, size: 28),
                      label: const Text(
                        'STOP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show Button - FIXED: Pass the bloc properly
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Builder(
                      builder: (context) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            // Get the bloc before navigation
                            final bloc = context.read<LocationBloc>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (newContext) => BlocProvider.value(
                                  value: bloc,
                                  child: const LocationsListScreen(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list, size: 28),
                          label: const Text(
                            'SHOW',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it works:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• START: Captures location every 10 seconds'),
                        Text('• Every 20 seconds: Syncs to server'),
                        Text('• STOP: Pauses location tracking'),
                        Text('• SHOW: Displays all saved locations'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return Colors.green;
      case TrackingStatus.stopped:
        return Colors.red;
      case TrackingStatus.idle:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return Icons.gps_fixed;
      case TrackingStatus.stopped:
        return Icons.gps_off;
      case TrackingStatus.idle:
        return Icons.gps_not_fixed;
    }
  }

  String _getStatusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return 'Tracking Active';
      case TrackingStatus.stopped:
        return 'Tracking Stopped';
      case TrackingStatus.idle:
        return 'Ready to Track';
    }
  }
}
