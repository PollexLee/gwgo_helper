import 'dart:collection';
import 'dart:convert';

import 'package:gwgo_helper/core/socket_core.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/model/location.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import '../sprite_ids.dart';
import '../config.dart';
import '../yaoling.dart';

class YaolingManager implements Callback {
  WebSocketCore socketCore;

  MockLocation leftBottomLocation = startList[xiyouList.indexOf(selectedDemon)];
  MockLocation rightTopLocation = endList[xiyouList.indexOf(selectedDemon)];

  Function callback;
  Function initSuccess;

  int lastRequestId;

  int id = 1;

  int requestCount = 1;

  init(Function initSuccess) {
    this.initSuccess = initSuccess;
    socketCore = WebSocketCore();
    // init会初始化四个WebSocket
    socketCore.init(50, this.initSuccess);
  }

  /// 刷新妖灵
  refreshYaoling(Function callback) async {
    print('开始扫描');
    this.id = 1;
    this.requestCount = 1;
    this.callback = callback;
    // 左下经纬度是0，说明是我的周围，根据当前位置来计算扫描经纬度
    if (leftBottomLocation.latitude == 0) {
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
    }
    var currentLat = leftBottomLocation.latitude;
    var currentLon = leftBottomLocation.longitude;

    bool isArea = true;
    // 从左到右
    bool leftToRight = true;
    int count = 0;
    while (isArea) {
      count++;
      await scanning(currentLat, currentLon);
      if (leftToRight) {
        currentLon += 18000;
        if (currentLon > rightTopLocation.longitude) {
          leftToRight = false;
          currentLat += 14000;
          currentLon -= 18000;
        }
      } else {
        currentLon -= 18000;
        if (currentLon < leftBottomLocation.longitude) {
          leftToRight = true;
          currentLat += 14000;
          currentLon += 18000;
        }
      }
      if (currentLat > rightTopLocation.latitude) {
        isArea = false;
      }
    }
    print('请求队列添加完成,共$count个请求');
  }

  Future scanning(int currentLat, int currentLon) async {
    /// 组建上传参数
    Map<String, dynamic> map = HashMap();
    JsonCodec jsonCodec = JsonCodec();
    map['request_type'] = '1001';
    map['longtitude'] = currentLon;
    map['latitude'] = currentLat;
    int requestid = id++;
    map['requestid'] = requestid;
    map['platform'] = 0;
    lastRequestId = requestid;
    await socketCore.send(requestid, jsonCodec.encode(map), this);
  }

  void close() {
    socketCore.close();
    callback = null;
  }

  @override
  onError(int code) {}

  @override
  onReceiveData(Map<String, dynamic> resultMap) {
    requestCount++;
    print('返回了$requestCount次数据');
    List<dynamic> spriteList = resultMap['sprite_list'];
    if (null == spriteList) {
      print('此处没有任何妖灵，resultMap = $resultMap');
      return;
    }
    List<Yaoling> yaolingList = List();
    spriteList.forEach((sprite) {
      Map<String, dynamic> spriteMap = sprite;
      Yaoling yaoling = Yaoling.fromjson(spriteMap);
      // 筛选出稀有
      if (SpriteConfig.selectedMap.keys.contains(yaoling.sprite_id)) {
        yaoling.name = SpriteConfig.selectedMap[yaoling.sprite_id];
        yaolingList.add(yaoling);
      }
    });
    // print('扫描到稀有妖灵${yaolingList.length}只');
    // if (yaolingList.isNotEmpty) {
    if (null != callback) {
      if (requestCount == id) {
        callback(yaolingList, '扫描完成');
      } else {
        callback(yaolingList, '扫描了$requestCount块/共$id块区域');
      }
    }

    if (requestCount == id) {
      close();
    }
  }
}
