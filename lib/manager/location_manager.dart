
import 'package:gwgo_helper/model/location.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

class LocationManager {
  static Future<Location> getLocation() async {
    return await getDeviceLocation();
  }
}
