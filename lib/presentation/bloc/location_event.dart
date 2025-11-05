import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class StartTracking extends LocationEvent {}

class StopTracking extends LocationEvent {}

class LoadLocations extends LocationEvent {}

class LocationError extends LocationEvent {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
