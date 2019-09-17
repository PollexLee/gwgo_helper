import 'package:gwgo_helper/model/location.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

import '../config.dart';

class LocationManager {
  /// 自定义选择的左下
  static var selectLeftBottomLocation;

  /// 自定义选择的右上
  static var selectRightTopLocation;

  static Future<Location> getLocation() async {
    return await getDeviceLocation();
  }

  /// 获取妖灵扫描区域
  static Future<List<MockLocation>> getYaolingScanningArea(
      Function callback) async {
    /// 获取设置的经纬度
    MockLocation leftBottomLocation =
        startList[locationList.indexOf(selectedLocation)];
    MockLocation rightTopLocation =
        endList[locationList.indexOf(selectedLocation)];

    /// 判断是那种选项，根据选项做位置获取

    if (leftBottomLocation.latitude == 0) {
      // 左下经纬度是0，说明是我的周围，根据当前位置来计算扫描经纬度
      print('获取要扫描的位置');
      callback(null, '正在获取定位');
      // 获取当前位置
      Location location = await getDeviceLocation();
      leftBottomLocation = MockLocation.fromLocation(location);
      int allDistance = distance;
      switch (rangeSelect) {
        case '极小':
          allDistance = distance ~/ 4;
          break;
        case '小':
          allDistance = distance;
          break;
        case '中':
          allDistance = distance + stemp;
          break;
        case '大':
          allDistance = distance + 2 * stemp;
          break;
      }

      rightTopLocation.latitude = leftBottomLocation.latitude + allDistance;
      rightTopLocation.longitude = leftBottomLocation.longitude + allDistance;
      leftBottomLocation.latitude -= allDistance;
      leftBottomLocation.longitude -= allDistance;
      print('获取到位置');
      callback(null, '扫描中');
    } else if (leftBottomLocation.longitude == -1) {
      // 左下经纬度是-1，说明是自定义位置，
      if (null == selectLeftBottomLocation || null == selectRightTopLocation) {
        toast('没有选择有效的自定义位置，请重新设置');
        return null;
      } else {
        leftBottomLocation = selectLeftBottomLocation;
        rightTopLocation = selectRightTopLocation;
      }
    }
    return [leftBottomLocation, rightTopLocation];
  }

  /// 获取擂台扫描区域
  static Future<List<MockLocation>> getLeitaiScanningArea() async {
    // 最大最小经纬度
    MockLocation leftBottomLocation =
        startList[locationList.indexOf(selectedLocation)];
    MockLocation rightTopLocation =
        endList[locationList.indexOf(selectedLocation)];
    // 左下经纬度是0，说明是我的周围，根据当前位置来计算扫描经纬度
    if (leftBottomLocation.latitude == 0) {
      Location location = await getDeviceLocation();
      leftBottomLocation = MockLocation.fromLocation(location);
      rightTopLocation.latitude = leftBottomLocation.latitude + leitai_distance;
      rightTopLocation.longitude =
          leftBottomLocation.longitude + leitai_distance;
      leftBottomLocation.latitude -= leitai_distance;
      leftBottomLocation.longitude -= leitai_distance;
    } else if (leftBottomLocation.longitude == -1) {
      // 左下经纬度是-1，说明是自定义位置切没有选择有效的位置
      toast('没有选择有效的自定义位置，请重新设置');
    }
    return [leftBottomLocation, rightTopLocation];
  }
}
