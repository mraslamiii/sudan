
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../../../core/utils/util.dart';

class LocationEnableManager {
  Future<bool> isLocationEnabled() async {
    var hasLocationPermission = await _checkPermission(4);
    return hasLocationPermission;
  }

  Future<bool> _checkPermission(int repeatCount) async {
    if (repeatCount == 0) {
      return false;
    }

    var status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      } else {
        return _checkPermission(repeatCount - 1);
      }
    } else if (status.isPermanentlyDenied) {
      Utils.snackError(
          'مجوز موقعیت مکانی برای همیشه از برنامه گرفته شده است.  لطفا از طریق تنظیمات اندروید، این محدودیت را بردارید.');
      return false;
    } else {
      // Means has permission
      return true;
    }
  }
}
