import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/manager/PackageInfoManager.dart';
import 'package:gwgo_helper/model/deviceInfo.dart';
import 'package:gwgo_helper/ui/promise/promise_model.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:gwgo_helper/utils/dialog_utils.dart';

/// 用户授权单例
class PromiseInstance {
// imei数据
  List<String> imeiList = List();
  // 网络时间
  int netTime = 0;
  // 我的有效时间
  DeviceInfo _deviceInfo;

  Map<String, int> currentMap = Map();

  Timer netTimeTimer;

  PromiseModel promiseModel;

  factory PromiseInstance(BuildContext context) => _promiseInstance(context);
  static PromiseInstance _instance;
  PromiseInstance._(BuildContext context) {
    init(context);
  }

  static PromiseInstance _promiseInstance(BuildContext context) {
    if (null == _instance) {
      return _instance = PromiseInstance._(context);
    } else {
      return _instance;
    }
  }

  /// 初始化所有数据, 有问题 弹窗提示
  init(BuildContext context) async {
    // 初始化版本信息
    PackageInfoManager.init();
    // 获取imei
    imeiList = await _getImeiList();
    if (imeiList == null || imeiList.isEmpty) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showPremissionDialog(context, null);
      return;
    }
    // 通过IMEI请求设备注册信息
    _deviceInfo = await _getMyDeviceInfo(context);
    // 注册信息为空，提示
    if (_deviceInfo == null) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showNetworkErrorDialog(context);
      return;
    }

    // _deviceInfo.version = '2.1.5|修复bug|1';
    // 根据版本信息做出提示
    if (null != _deviceInfo.version && _deviceInfo.version.isNotEmpty) {
      try {
        var versionArray = _deviceInfo.version.split('|');
        var version = versionArray[0];
        var msg = versionArray[1];
        var force = versionArray[2];

        if (version != PackageInfoManager.packageVersion) {
          DialogUtils.hideProgressDialog();
          DialogUtils.showUpdateDialog(context, version, msg, true);
          return;
        } else {
          DialogUtils.hideProgressDialog();
          DialogUtils.showNotificationDialog(context, msg);
        }
      } catch (exception) {
        print('版本更新数据解析异常: $exception');
      }
    }

    // 获取当前网络时间
    netTime = await getNetTime();
    if (netTime <= 0) {
      DialogUtils.hideProgressDialog();
      DialogUtils.showNetworkErrorDialog(context);
      return;
    }

    // 获取我的注册时间
    // myRegisteTime = _getMyRegisteTime();

    // filterMyDeviceInfo(context);
  }

  /// 从网络获取设备信息
  Future<DeviceInfo> _getMyDeviceInfo(BuildContext context) async {
    var dio = Dio();
    dio.options.headers.addAll({'Content-Type': 'application/json'});
    try {
      //   Response response = await dio
      // .get('http://192.168.123.137:8848/getDeviceInfo?imei=${imeiList[0]}');
      // Response response = await dio
      //     .get('http://65.49.213.166:8848/getDeviceInfo?imei=${imeiList[0]}');
      Response response = await dio
          .get('http://gwgo.pollex.me:8848/getDeviceInfo?imei=${imeiList[0]}');
      print(response.data);
      DeviceInfo deviceInfo = DeviceInfo.fromJson(response.data);

      // 每个用户都有权限，到9月22日
      //  DeviceInfo deviceInfo = DeviceInfo();
      //  deviceInfo.expireTime = 1570377600000;
      if (deviceInfo.expireTime < 1570377600000) {
        deviceInfo.expireTime = 1570377600000;
      }
      // 取出token字段
      token = deviceInfo.token;
      openid = deviceInfo.openid;

      return deviceInfo;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// 是否通过权限校验
  Future<bool> isPromise(BuildContext context) async {
    // 判断是否获取到了IMEI
    if (imeiList == null || imeiList.isEmpty) {
      imeiList = await _getImeiList();
    }
    if (imeiList == null || imeiList.isEmpty) {
      DialogUtils.showPremissionDialog(context, null);
      return false;
    }
    //判断是否获取到网络时间
    if (netTime <= 0) {
      netTime = await getNetTime();
    }
    if (netTime <= 0) {
      DialogUtils.showNetworkErrorDialog(context);
      return false;
    }

    // 获取我的设备信息
    if (_deviceInfo == null) {
      DialogUtils.showProgressDialog(context, "正在获取注册信息...");
      _deviceInfo = await _getMyDeviceInfo(context);
      DialogUtils.hideProgressDialog();
      if (_deviceInfo == null) {
        DialogUtils.showNetworkErrorDialog(context);
        return false;
      }
    }

    if (null != _deviceInfo.version && _deviceInfo.version.isNotEmpty) {
      try {
        var versionArray = _deviceInfo.version.split('|');
        var version = versionArray[0];
        var msg = versionArray[1];
        var force = versionArray[2];
        if (version != PackageInfoManager.packageVersion) {
          DialogUtils.hideProgressDialog();
          DialogUtils.showUpdateDialog(context, version, msg, true);
          return false;
        }
      } catch (exception) {
        print('版本更新数据解析异常: $exception');
      }
    }

    // 有效期小于当前时间
    if (_deviceInfo.expireTime < netTime) {
      // 到期
      DialogUtils.showRegistDialog(context, imeiList[0], true);
      return false;
    } else {
      // 没到期
      return true;
    }
  }

  Future<List<String>> _getImeiList() async {
    try {
      Map<String, dynamic> imeiMap = await getDeviceImei();
      List<dynamic> temp = imeiMap['imei'];
      if(temp == null){
        print('获取设备id，异常了,getDeviceImei() return null');
        return List<String>(0);
      }
      imeiList = temp.map<String>((item) {
        return item;
      }).toList();
      if (imeiList == null ||
          imeiList.isEmpty ||
          imeiList[0] == null ||
          imeiList[0] == 'null') {
        return List<String>(0);
      }
      return imeiList;
    } catch (exception) {
      print('获取设备id，异常了 $exception');
      return List<String>(0);
    }
  }

  /// 获取网络时间，有时间
  Future<int> getNetTime() async {
    if (netTime > 0) {
      return netTime;
    } else {
      Dio dio = Dio();
      dio.options.responseType = ResponseType.json;
      try {
        Response response = await dio.get(
            'https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp');
        Map<String, dynamic> result = response.data;
        print(result);
        Map<String, dynamic> data = result['data'];
        int timestemp = int.parse(data['t']);
        print('timestemp = $timestemp');
        this.netTime = timestemp;
        if (null != netTimeTimer) {
          netTimeTimer.cancel();
          netTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            netTime += 1000;
          });
        }
        return timestemp;
      } catch (exception) {
        print(exception);
        return 0;
      }
    }
  }

  /// 获取有效期相关提示
  String getLastTime() {
    if (_deviceInfo == null) {
      return '设备未注册';
    }
    if (netTime <= 0) {
      return '网络异常，请联网后重启';
    }
    if (_deviceInfo.expireTime < netTime) {
      return '注册已过期';
    } else {
      var format = DateTime.fromMillisecondsSinceEpoch(_deviceInfo.expireTime);
      return '到期时间：${format.year}-${format.month}-${format.day} ${format.hour}:${format.minute}';
    }
  }
}
