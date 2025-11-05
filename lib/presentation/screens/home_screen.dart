import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_doctor/presentation/widgets/app_button.dart';
import 'package:sales_doctor/presentation/widgets/info_card.dart';
import 'package:sales_doctor/presentation/widgets/status_indicator.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import 'locations_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        elevation: 2,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
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
          final isTracking = state.trackingStatus == TrackingStatus.tracking;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusIndicator(status: state.trackingStatus),
                  const SizedBox(height: 48),

                  AppButton(
                    label: 'START',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    isEnabled: !isTracking,
                    onPressed: () =>
                        context.read<LocationBloc>().add(StartTracking()),
                  ),
                  const SizedBox(height: 16),

                  AppButton(
                    label: 'STOP',
                    icon: Icons.stop,
                    color: Colors.red,
                    isEnabled: isTracking,
                    onPressed: () =>
                        context.read<LocationBloc>().add(StopTracking()),
                  ),
                  const SizedBox(height: 16),
                  _buildShowButton(context),
                  const SizedBox(height: 32),

                  const InfoCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AppButton(
        label: 'SHOW',
        icon: Icons.list,
        color: Colors.blue,
        isEnabled: true,
        onPressed: () {
          final bloc = context.read<LocationBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const LocationsListScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
