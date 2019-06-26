import 'dart:collection';
import 'dart:convert';

import 'package:gwgo_helper/core/socket_core.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/model/leitai.dart';
import 'package:gwgo_helper/model/location.dart';
import 'package:gwgo_helper/utils/common_utils.dart';

import '../config.dart';

class LeitaiManager implements Callback {
  WebSocketCore socketCore;
  // 最大最小经纬度
  MockLocation leftBottomLocation = startList[xiyouList.indexOf(selectedDemon)];
  MockLocation rightTopLocation = endList[xiyouList.indexOf(selectedDemon)];

  Function callback;
  Function initSuccess;

  int lastRequestId;

  int id = 1;

  init(Function initSuccess) {
    this.initSuccess = initSuccess;
    socketCore = WebSocketCore();
    // init会初始化四个WebSocket
    socketCore.init(10, this.initSuccess);
  }

  /// 刷新擂台
  refreshLeitai(Function callback) async {
    id = 1;
    this.callback = callback;

    // 左下经纬度是0，说明是我的周围，根据当前位置来计算扫描经纬度
    if (leftBottomLocation.latitude == 0) {
      Location location = await getDeviceLocation();
      leftBottomLocation = MockLocation.fromLocation(location);
      rightTopLocation.latitude = leftBottomLocation.latitude + distance;
      rightTopLocation.longitude = leftBottomLocation.longitude + distance;
      leftBottomLocation.latitude -= distance;
      leftBottomLocation.longitude -= distance;
    }

    var currentLat = leftBottomLocation.latitude;
    var currentLon = leftBottomLocation.longitude;

    bool isArea = true;
    int count = 0;
    while (isArea) {
      count++;
      scanning(currentLat, currentLon);
      // 扫描擂台距离是多少？
      if ((currentLon += 45000) < rightTopLocation.longitude) {
        // scanning(currentLat, currentLon);
      } else {
        currentLat += 35000;
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
    int requestid = id++;
    map['requestid'] = requestid;
    map['platform'] = 0;
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
    List<dynamic> tempList = resultMap['dojo_list'];
    List<Leitai> leitaiList = List();
    if(tempList == null || tempList.isEmpty){
      tempList = List();
    }
    tempList.forEach((sprite) {
      Map<String, dynamic> spriteMap = sprite;
      Leitai leitai = Leitai.fromJson(spriteMap);
      if (leitai.latitude != 0 && leitai.longtitude != 0) {
        leitaiList.add(leitai);
      }
    });
    print('扫描到擂台${leitaiList.length}个');
    if (leitaiList.isNotEmpty) {
      callback(leitaiList);
    }
  }
}
