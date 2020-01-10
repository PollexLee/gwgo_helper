import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gwgo_helper/manager/location_manager.dart';
import 'package:gwgo_helper/model/leitai.dart';
import 'dart:math';
import 'package:gwgo_helper/model/location.dart';
import '../config.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';

//获取到插件与原生的交互通道
const jumpPlugin = const MethodChannel('com.pollex.gwgo/plugin');

startSelectLocation(Function listener) {
  jumpPlugin.setMethodCallHandler((MethodCall call) async {
    assert(call.method == 'setMockLocation');
    print('setMockLocation, 参数是：${call.arguments}');
    listener(call.arguments.toString());
  });
  mackLocation();
}

setSelectArea(Function listener) {
  jumpPlugin.setMethodCallHandler((MethodCall call) async {
    assert(call.method == 'setArea');
    listener(call.arguments.toString());
  });
  openSelectAreaPage();
}

Future teleport(double lat, double lon) async {
  // 计算目地位置
  List<double> wgsLocation = gcj02towgs84(lon, lat);

  if (isOpenFly) {
    _flyFromTo(wgsLocation[1], wgsLocation[0]);
  } else {
    // 复制到粘贴板
    Clipboard.setData(
        ClipboardData(text: '${wgsLocation[1]},${wgsLocation[0]}'));
    toast('已复制经纬度');
  }
}

/**
 * 从现在位置飞到xx，递归
 */
_flyFromTo(double toLat, double toLon) async {
  // 获取当前位置
  try {
    var location = await LocationManager.getLocation();
    print('获取到了位置：${location.latitude} ${location.longitude}');

    double latDiff = toLat - location.latitude;
    double lonDiff = toLon - location.longitude;

    // 计算距离
    double distance = sqrt(latDiff * latDiff + lonDiff * lonDiff);
    print('间隔距离是：$distance');
    if (!isOpenMultiFly) {
      // 没有开启多次飞行
      await _fly(toLat, toLon, isStartAir);
      print('飞行结束');
    } else {
      if (distance < 0.04) {
        // 一次飞行
        await _fly(toLat, toLon, isStartAir);
        print('飞行结束');
        toast('到达目地低');
      } else {
        // todo  多次分行 计算还有问题
        print('飞行了一次，还要继续飞行');
        double biggest = max(latDiff.abs(), lonDiff.abs());

        /// 移动距离 / 最大距离Î
        var moveLat = latDiff / biggest * 0.01;
        var moveLon = lonDiff / biggest * 0.01;
        _fly(
            double.parse((location.latitude + moveLat).toStringAsFixed(6)),
            double.parse((location.longitude + moveLon).toStringAsFixed(6)),
            isStartAir);
        Timer(Duration(seconds: 2), () {
          _flyFromTo(toLat, toLon);
        });
      }
    }
  } catch (exception) {
    print('出现了异常：$exception');
    await toast('飞行异常$exception');
  }
}

_fly(double flyLat, double flyLon, bool startGame) async {
  if (Platform.isAndroid) {
    Map<String, dynamic> map = {
      "lat": flyLat,
      'lon': flyLon,
      'startGame': startGame,
      'plain': selectPlain,
    };
    String result = await jumpPlugin.invokeMethod('teleport', map);
    print(result);
  }
}

//定义一些常量
const x_PI = 3.14159265358979324 * 3000.0 / 180.0;
const PI = 3.1415926535897932384626;
const a = 6378245.0;
const ee = 0.00669342162296594323;

List<double> gcj02towgs84(lng, lat) {
  var dlat = transformlat(lng - 105.0, lat - 35.0);
  var dlng = transformlng(lng - 105.0, lat - 35.0);
  var radlat = lat / 180.0 * PI;
  var magic = sin(radlat);
  magic = 1 - ee * magic * magic;
  var sqrtmagic = sqrt(magic);
  dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
  dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * PI);
  var mglat = lat + dlat;
  var mglng = lng + dlng;
  return [lng * 2 - mglng, lat * 2 - mglat];
}

transformlat(lng, lat) {
  var ret = -100.0 +
      2.0 * lng +
      3.0 * lat +
      0.2 * lat * lat +
      0.1 * lng * lat +
      0.2 * sqrt(lng.abs());
  ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(lat * PI) + 40.0 * sin(lat / 3.0 * PI)) * 2.0 / 3.0;
  ret +=
      (160.0 * sin(lat / 12.0 * PI) + 320 * sin(lat * PI / 30.0)) * 2.0 / 3.0;
  return ret;
}

transformlng(lng, lat) {
  var ret = 300.0 +
      lng +
      2.0 * lat +
      0.1 * lng * lng +
      0.1 * lng * lat +
      0.1 * sqrt(lng.abs());
  ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0;
  ret += (20.0 * sin(lng * PI) + 40.0 * sin(lng / 3.0 * PI)) * 2.0 / 3.0;
  ret +=
      (150.0 * sin(lng / 12.0 * PI) + 300.0 * sin(lng / 30.0 * PI)) * 2.0 / 3.0;
  return ret;
}

/// 请求设备位置
Future<Location> getDeviceLocation() => jumpPlugin
    .invokeMethod('getLocation')
    .then((result) => Location.fromMap(result.cast<String, double>()));

Future<Map<String, dynamic>> getDeviceImei() => jumpPlugin
    .invokeMethod('getImei')
    .then((result) => result.cast<String, dynamic>());

Future<String> toast(String content) =>
    jumpPlugin.invokeMethod('toast', content);

/// 启动飞行器
dynamic openAir(double flyLat, double flyLon, bool start) async {
  Map<String, dynamic> map = {"lat": flyLat, 'lon': flyLon, 'start': start};
  return await jumpPlugin.invokeMethod('openAir', map);
}

dynamic getAirStatus() async {
  return await jumpPlugin.invokeMethod('getAirStatus');
}

dynamic setFloatVisiable(bool visiable) async {
  Map<String, dynamic> map = {"float": visiable};
  return await jumpPlugin.invokeMethod('float', map);
}

dynamic leitaiMap(List<Leitai> leitaiList) async {
  String params = jsonEncode(leitaiList);
  print(params);
  await jumpPlugin.invokeMethod('leitaiMap', params);
}

dynamic mackLocation() async {
  await jumpPlugin.invokeMethod('mockLocation');
}

String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

dynamic openSelectAreaPage() async {
  await jumpPlugin.invokeMethod('openSelectAreaPage');
}

dynamic openQQ(String qq) async {
  await jumpPlugin.invokeMethod('openQQ', qq);
}

dynamic openQQGroup() async {
  await jumpPlugin.invokeMethod('openQQGroup');
}
