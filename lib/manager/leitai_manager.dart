import 'dart:collection';
import 'dart:convert';

import 'package:gwgo_helper/core/socket_core.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/model/leitai.dart';

import 'location_manager.dart';

class LeitaiManager implements Callback {
  WebSocketCore socketCore;

  Function callback;
  Function initSuccess;

  int lastRequestId;

  int id = 0;
  int count = 0;

  int maxLong = 0;
  int maxLati = 0;

  init(Function initSuccess) {
    this.initSuccess = initSuccess;
    socketCore = WebSocketCore();
    // init会初始化四个WebSocket
    socketCore.init(10, this.initSuccess);
  }

  /// 刷新擂台
  refreshLeitai(Function callback) async {
    id = 0;
    this.callback = callback;

    var area = await LocationManager.getLeitaiScanningArea();

    if (null == area) {
      return;
    }
    var leftBottomLocation = area[0];
    var rightTopLocation = area[1];

    var currentLat = leftBottomLocation.latitude;
    var currentLon = leftBottomLocation.longitude;

    bool isArea = true;
    int count = 0;
    while (isArea) {
      count++;
      scanning(currentLat, currentLon);
      // 扫描擂台距离是多少？
      if ((currentLon += 44000) < rightTopLocation.longitude) {
        // scanning(currentLat, currentLon);
      } else {
        currentLat += 34000;
        currentLon = leftBottomLocation.longitude;
        if (currentLat > rightTopLocation.latitude) {
          isArea = false;
        }
      }
    }
    print('请求队列添加完成,共$count个请求');
  }

  void scanning(int currentLat, int currentLon) {
    /// 组建上传参数
    Map<String, dynamic> map = HashMap();
    JsonCodec jsonCodec = JsonCodec();
    map['request_type'] = '1002';
    map['longtitude'] = currentLon;
    map['latitude'] = currentLat;
    int requestid = ++id;
    map['requestid'] = requestid;
    map['platform'] = '0';
    lastRequestId = requestid;
    socketCore.send(requestid, jsonCodec.encode(map), this);
  }

  void close() {
    socketCore.close();
  }

  @override
  onError(int code) {}

  @override
  onReceiveData(Map<String, dynamic> resultMap) {
    count++;
    List<dynamic> tempList = resultMap['dojo_list'];
    List<Leitai> leitaiList = List();
    if (tempList == null || tempList.isEmpty) {
      tempList = List();
    }
    int minLon = 36000000000;
    int minLat = 36000000000;
    int maxLon = 0;
    int maxLat = 0;

    tempList.forEach((sprite) {
      Map<String, dynamic> spriteMap = sprite;
      Leitai leitai = Leitai.fromJson(spriteMap);
      if (leitai.latitude != 0 && leitai.longtitude != 0) {
        leitaiList.add(leitai);
        if (leitai.longtitude < minLon) {
          minLon = leitai.longtitude;
        }
        if (leitai.longtitude > maxLon) {
          maxLon = leitai.longtitude;
        }
        if (leitai.latitude < minLat) {
          minLat = leitai.latitude;
        }
        if (leitai.latitude > maxLat) {
          maxLat = leitai.latitude;
        }
      }
    });

    if ((maxLat - minLat) > maxLati) {
      maxLati = maxLat - minLat;
    }
    if ((maxLon - minLon) > maxLong) {
      maxLong = maxLon - minLon;
    }
    print('本次间隔距离：maxLong = $maxLong, maxLati = $maxLati.');

    print('扫描到擂台${leitaiList.length}个');
    if (count == id) {
      callback(leitaiList, '扫描完成');
    } else {
      callback(leitaiList, '进度 $count/$id');
    }
  }
}
