import 'package:equatable/equatable.dart';
import '../models/location_model.dart';

enum TrackingStatus { idle, tracking, stopped }

enum LocationLoadingStatus { initial, loading, loaded, error }

class LocationState extends Equatable {
  final TrackingStatus trackingStatus;
  final LocationLoadingStatus loadingStatus;
  final List<LocationModel> locations;
  final String? errorMessage;

  const LocationState({
    this.trackingStatus = TrackingStatus.idle,
    this.loadingStatus = LocationLoadingStatus.initial,
    this.locations = const [],
    this.errorMessage,
  });

  LocationState copyWith({
    TrackingStatus? trackingStatus,
    LocationLoadingStatus? loadingStatus,
    List<LocationModel>? locations,
    String? errorMessage,
  }) {
    return LocationState(
      trackingStatus: trackingStatus ?? this.trackingStatus,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    trackingStatus,
    loadingStatus,
    locations,
    errorMessage,
  ];
}
