import '../../../domain/usecases/user_location/user_location_usecase.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/globals.dart';

class UserLocationUseCaseImpl extends UserLocationUseCase {
  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  /// 
  /// Note: geolocator removed, returning mock location
  /// Use permission_handler for location permissions

  @override
  Future<Map<String, double>> getLocation() async {
    // Check location permission using permission_handler
    var status = await Permission.location.status;
    
    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isDenied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (status.isPermanentlyDenied) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Return mock location since geolocator is removed
    // In production, integrate a location service
    return {
      'latitude': 0.0,
      'longitude': 0.0,
    };
  }

  void _logger(String key, String value) {
    doLogGlobal('user_location_usecase_impl. H:$hashCode', key, value);
  }
}
