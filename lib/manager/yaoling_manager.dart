import 'dart:collection';
import 'dart:convert';

import 'package:gwgo_helper/core/socket_core.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/model/location.dart';
import '../sprite_ids.dart';
import '../config.dart';
import '../yaoling.dart';
import 'location_manager.dart';
import 'yaoling_info.dart';

class YaolingManager implements Callback {
  WebSocketCore socketCore;

  MockLocation leftBottomLocation =
      startList[locationList.indexOf(selectedLocation)];
  MockLocation rightTopLocation =
      endList[locationList.indexOf(selectedLocation)];

  Function callback;
  Function initSuccess;

  int lastRequestId;

  int id = 0;

  int requestCount = 0;

  init(Function initSuccess) {
    this.initSuccess = initSuccess;
    socketCore = WebSocketCore();
    // init会初始化四个WebSocket
    socketCore.init(50, this.initSuccess);
  }

  /// 刷新妖灵
  refreshYaoling(Function callback) async {
    print('开始扫描');
    this.id = 0;
    this.requestCount = 0;
    this.callback = callback;

    List<MockLocation> area =
        await LocationManager.getYaolingScanningArea(callback);
    if (null == area) {
      return;
    }
    leftBottomLocation = area[0];
    rightTopLocation = area[1];

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
      // 是否包含在选中类表
      if (SpriteConfig.selectedMap.keys.contains(yaoling.sprite_id)) {
        yaoling.name = SpriteConfig.selectedMap[yaoling.sprite_id];
        yaolingList.add(yaoling);
      }
      // else if (!YaolingInfoManager.yaolingMap.keys
      //     .contains(yaoling.sprite_id)) {
      //   // 是否包含在配置列表中
      //   if (yaoling.sprite_id != 2004041) {
      //     yaoling.name = yaoling.sprite_id.toString();
      //     yaolingList.add(yaoling);
      //   }
      // }
    });

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
