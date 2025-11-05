import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works (Background Sync):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: 8),
          Text('• START: Captures location every 10 seconds (DB1)'),
          Text(
            '• Every 20 seconds: Moves data from DB1 to DB2, then syncs DB2 to server.',
          ),
          Text('• STOP: Pauses location tracking.'),
          Text('• SHOW: Displays all locations fetched from the server.'),
        ],
      ),
    );
  }
}
