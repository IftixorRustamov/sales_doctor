import 'package:flutter/material.dart';
import 'package:sales_doctor/models/location_model.dart';
import 'package:sales_doctor/presentation/widgets/location_view_model.dart';
import 'info_row.dart';

class LocationCard extends StatelessWidget {
  final LocationModel location;
  final int index;

  const LocationCard({super.key, required this.location, required this.index});

  @override
  Widget build(BuildContext context) {
    final viewModel = LocationViewModel(location);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${viewModel.formattedDate} at ${viewModel.formattedTime}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          viewModel.latLongShort,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(
                  icon: Icons.location_on,
                  label: 'Latitude (Raw)',
                  value: location.latitude.toString(),
                ),
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.location_on,
                  label: 'Longitude (Raw)',
                  value: location.longitude.toString(),
                ),
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.access_time,
                  label: 'Date & Time (Local)',
                  value:
                      '${viewModel.formattedDate} ${viewModel.formattedTime}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
