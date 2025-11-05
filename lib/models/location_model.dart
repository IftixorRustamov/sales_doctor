import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final int? id;
  final double latitude;
  final double longitude;
  final String timestamp;
  final int synced;

  const LocationModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'synced': synced,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: map['timestamp'] as String,
      synced: map['synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  factory LocationModel.fromFirestore(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: map['timestamp'] as String,
      synced: 1,
    );
  }

  @override
  List<Object?> get props => [id, latitude, longitude, timestamp, synced];
}
