import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_doctor/data/location_repository.dart';
import '../../utils/app_logger.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;

  LocationBloc({required LocationRepository locationRepository})
    : _repository = locationRepository,
      super(const LocationState()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<LoadLocations>(_onLoadLocations);
    on<LocationError>(_onError);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        trackingStatus: TrackingStatus.tracking,
        errorMessage: null,
      ),
    );

    appLogger.i('Handling StartTracking event...');

    final hasPermission = await _repository.checkPermissions();

    if (!hasPermission) {
      const errorMessage =
          'Location permissions denied or service disabled. Cannot start tracking.';
      appLogger.e(errorMessage);

      emit(
        state.copyWith(
          trackingStatus: TrackingStatus.idle,
          errorMessage: errorMessage,
        ),
      );
      return;
    }

    try {
      _repository.startTracking();
      appLogger.i('Tracking started successfully.');
    } catch (e) {
      const errorMessage = 'Failed to initialize background tracking service.';
      appLogger.e('$errorMessage Error: $e');

      emit(
        state.copyWith(
          trackingStatus: TrackingStatus.idle,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onStopTracking(StopTracking event, Emitter<LocationState> emit) {
    appLogger.i('Handling StopTracking event...');
    _repository.stopTracking();

    emit(
      state.copyWith(
        trackingStatus: TrackingStatus.stopped,
        errorMessage: null,
      ),
    );
    appLogger.i('Tracking stopped.');
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingStatus: LocationLoadingStatus.loading,
        errorMessage: null,
      ),
    );

    appLogger.i('Handling LoadLocations event (fetching from Firebase)...');

    try {
      final locations = await _repository.getLocationsFromFirebase();

      emit(
        state.copyWith(
          loadingStatus: LocationLoadingStatus.loaded,
          locations: locations,
        ),
      );
      appLogger.i('Successfully loaded ${locations.length} locations.');
    } catch (e) {
      const errorMessage = 'Failed to fetch locations from server.';
      appLogger.e('$errorMessage Error: $e');

      emit(
        state.copyWith(
          loadingStatus: LocationLoadingStatus.error,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onError(LocationError event, Emitter<LocationState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  @override
  Future<void> close() {
    _repository.dispose();
    appLogger.i('LocationBloc disposed and repository cleaned up.');
    return super.close();
  }
}
