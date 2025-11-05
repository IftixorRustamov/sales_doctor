import 'package:flutter/material.dart';
import 'package:sales_doctor/presentation/bloc/location_state.dart';

class StatusIndicator extends StatelessWidget {
  final TrackingStatus status;

  const StatusIndicator({super.key, required this.status});

  Color _getColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return Colors.green;
      case TrackingStatus.stopped:
        return Colors.red;
      case TrackingStatus.idle:
        return Colors.blueGrey;
    }
  }

  IconData _getIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return Icons.gps_fixed;
      case TrackingStatus.stopped:
        return Icons.gps_off;
      case TrackingStatus.idle:
        return Icons.gps_not_fixed;
    }
  }

  String _getText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.tracking:
        return 'Tracking Active';
      case TrackingStatus.stopped:
        return 'Tracking Stopped';
      case TrackingStatus.idle:
        return 'Ready to Track';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    final icon = _getIcon(status);
    final text = _getText(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
