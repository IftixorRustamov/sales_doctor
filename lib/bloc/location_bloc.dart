import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository locationRepository;

  LocationBloc({required this.locationRepository})
    : super(const LocationState()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<LoadLocations>(_onLoadLocations);
    on<LocationError>(_onLocationError);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      // Check permissions
      final hasPermission = await locationRepository.checkPermissions();
      if (!hasPermission) {
        emit(
          state.copyWith(
            trackingStatus: TrackingStatus.stopped,
            errorMessage: 'Location permissions not granted',
          ),
        );
        return;
      }

      // Start tracking
      locationRepository.startTracking((error) {
        add(LocationError(error));
      });

      emit(
        state.copyWith(
          trackingStatus: TrackingStatus.tracking,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          trackingStatus: TrackingStatus.stopped,
          errorMessage: 'Error starting tracking: $e',
        ),
      );
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationState> emit,
  ) async {
    locationRepository.stopTracking();
    emit(
      state.copyWith(
        trackingStatus: TrackingStatus.stopped,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: LocationLoadingStatus.loading));

    try {
      final locations = await locationRepository.getLocationsFromFirebase();
      emit(
        state.copyWith(
          loadingStatus: LocationLoadingStatus.loaded,
          locations: locations,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingStatus: LocationLoadingStatus.error,
          errorMessage: 'Error loading locations: $e',
        ),
      );
    }
  }

  void _onLocationError(LocationError event, Emitter<LocationState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  @override
  Future<void> close() {
    locationRepository.dispose();
    return super.close();
  }
}
