import 'package:intl/intl.dart';
import 'package:sales_doctor/models/location_model.dart';

class LocationViewModel {
  final LocationModel location;
  final String formattedDate;
  final String formattedTime;
  final String latLongShort;
  final String mapsUrl;

  LocationViewModel(this.location)
    : formattedDate = DateFormat(
        'MMM dd, yyyy',
      ).format(DateTime.parse(location.timestamp)),
      formattedTime = DateFormat(
        'HH:mm:ss',
      ).format(DateTime.parse(location.timestamp)),
      latLongShort =
          'Lat: ${location.latitude.toStringAsFixed(6)}, Long: ${location.longitude.toStringAsFixed(6)}',
      mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
}
