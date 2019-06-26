import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

import 'package:gwgo_helper/yaoling.dart';

import 'model/leitai.dart';
import 'sprite_ids.dart';

/// ,  ,

// final MIN_LAT = 39852829;
// final MAX_LAT = 39971332;
// final MIN_LON = 116308823;
// final MAX_LON = 116460571;

final MIN_LAT = 39676541;
final MAX_LAT = 39826468;
final MIN_LON = 116256638;
final MAX_LON = 116434479;

int LEITAI_TYPE_NORMAL = 0;
final LEITAI_TYPE_EGG = 1;
final LEITAI_TYPE_GROUP = 2;
final YAOLING = 3;

/**
 * 接口请求类，循环，
 */
class RadarSocket {
  static String URL =
      "wss://publicld.gwgo.qq.com?account_value=0&account_type=0&appid=0&token=0";
  WebSocket socket;

  /// 是否建立连接
  var isConnect = false;

  /// 循环请求的延时，五秒以下，第三次请求就没有数据了
  final delayTime = 10;

  /// 是否暂停
  var isPause = false;

  Function onConnect;
  int requestType = 0;

  Function onReceiveData;

  /// 上一次扫描的经纬度
  int lastLat;
  int lastLon;

  /// 用于循环请求的定时器
  Timer timer;

  /// 用户记录本次刷新的request id
  List<int> requestIdList = List();
  List<int> responseIdList = List();

  /// 初始化
  init(int type, Function onConnect) {
    requestType = type;
    this.onConnect = onConnect;
    connect();
  }

  /// 建立连接
  connect() async {
    onConnect(1);
    try {
      socket = await WebSocket.connect(URL);
    } catch (e) {
      print('建立连接异常：$e');
      onConnect(0);
      return;
    }
    socket.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: false,
    );
  }

  void refresh(Function f) {
    this.onReceiveData = f;
    isPause = false;
    requestIdList.clear();
    responseIdList.clear();
    if (timer != null && timer.isActive) {
      timer.cancel();
      timer = null;
    }
    scanning(MIN_LAT, MIN_LON);
  }

  void scanning(int lat, int lon) {
    print(
        '开始扫描 lat = $lat, lon = $lon,时间是：${DateTime.now()}，requestType = $requestType');

    /// 给扫描缓存经纬度赋值
    lastLat = lat;
    lastLon = lon;

    /// 组建上传参数
    Map<String, dynamic> map = HashMap();
    JsonCodec jsonCodec = JsonCodec();
    if (requestType == YAOLING) {
      // 妖灵
      map['request_type'] = '1001';
    } else if (requestType == LEITAI_TYPE_NORMAL ||
        requestType == LEITAI_TYPE_GROUP ||
        requestType == LEITAI_TYPE_EGG) {
      // 擂台
      map['request_type'] = '1002';
    }
    map['longtitude'] = lon;
    map['latitude'] = lat;
    int requestid = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    requestIdList.add(requestid);
    map['requestid'] = requestid;
    map['platform'] = 0;
    // write(jsonCodec.encode(map));
    // 开启计时器，2s后没有返回数据，继续写入
    loopWrite(jsonCodec.encode(map));
  }

  loopWrite(String params) {
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      write(params);
    });
    // write(params);
  }

  bool cancel() {
    isPause = true;
    if (null != socket) {
      socket.close();
      socket = null;
    }
    if (timer != null && timer.isActive) {
      timer.cancel();
      timer = null;
    }
  }

  void dataHandler(data) {
    // print("data type is ${data.runtimeType}");
    if (timer != null && timer.isActive) {
      timer.cancel();
      timer = null;
    }
    if (data.runtimeType == String && data.toString().contains('pass')) {
      isConnect = true;
      var dataStr = data.toString();
      print(dataStr);
      onConnect(2);
    } else {
      Uint8List list = data;
      Utf8Decoder decoder = Utf8Decoder();
      String result = decoder.convert(list.sublist(4));
      result = result.replaceAll(String.fromCharCode(0x08), '');
      result = result.replaceAll(String.fromCharCode(0x07), '');
      result = result.replaceAll(String.fromCharCode(0x7f), '');
      JsonCodec jsonCodec = JsonCodec();
      Map<String, dynamic> resultMap = Map();
      try {
        resultMap = jsonCodec.decode(result);
      } catch (exc) {
        print(exc.toString());
        print(list);
      }
      if (resultMap.containsKey('requestid')) {
        int requestId = resultMap['requestid'];
        if (requestIdList.contains(requestId) &&
            !responseIdList.contains(requestId)) {
          // 请求列表中有id，响应中没有id，说明是需要处理的请求
          responseIdList.add(requestId);
        } else {
          // 请求列表中没有id，或者响应列表中有id，说明 没有发此请求，或已经返回了此请求，不做处理
          return;
        }
      }

      // 计算最大最小经纬度
      int minLat = 100000000;
      int minLon = 1000000000;
      int maxLat = 0;
      int maxLon = 0;
      // 需要区分是妖灵还是擂台
      if (resultMap.containsKey('dojo_list')) {
        // 擂台
        List<dynamic> tempList = resultMap['dojo_list'];
        List<Leitai> leitaiList = List();
        tempList.forEach((item) {
          Map<String, dynamic> temp = item;
          Leitai leitai = Leitai.fromJson(temp);
          if (leitai.latitude != 0 && leitai.longtitude != 0) {
            // 排除经纬度无效的数据
            if (requestType == LEITAI_TYPE_GROUP &&
                leitai.isGroup() &&
                leitai.starlevel == 5) {
              // 是五级 御灵团战
              leitaiList.add(leitai);
            } else if (requestType == LEITAI_TYPE_NORMAL && leitai.isNormal()) {
                leitaiList.add(leitai);
            }
            // 对比出经纬度最大和最小
            int latitude = temp['latitude'];
            int longtitude = temp['longtitude'];
            if (minLat > latitude) {
              minLat = latitude;
            }
            if (minLon > longtitude) {
              minLon = longtitude;
            }
            if (maxLat < latitude) {
              maxLat = latitude;
            }
            if (maxLon < longtitude) {
              maxLon = longtitude;
            }
          }
        });
        print('扫描 lat = $lastLat, lon = $lastLon,扫描到${leitaiList.length}个五星擂台');
        if (!isPause) {
          onReceiveData(leitaiList);
        }
      } else {
        // 妖灵
        List<dynamic> spriteList = resultMap['sprite_list'];
        List<Yaoling> yaolingList = List();
        spriteList.forEach((sprite) {
          Map<String, dynamic> spriteMap = sprite;
          Yaoling yaoling = Yaoling.fromjson(spriteMap);
          // 筛选出稀有
          if (SpriteConfig.spriteMap.keys.contains(yaoling.sprite_id)) {
            yaoling.name = SpriteConfig.spriteMap[yaoling.sprite_id];
            yaolingList.add(yaoling);
          }

          // 对比出经纬度最大和最小
          if (minLat > yaoling.latitude) {
            minLat = yaoling.latitude;
          }
          if (minLon > yaoling.longtitude) {
            minLon = yaoling.longtitude;
          }
          if (maxLat < yaoling.latitude) {
            maxLat = yaoling.latitude;
          }
          if (maxLon < yaoling.longtitude) {
            maxLon = yaoling.longtitude;
          }
        });
        print('扫描 lat = $lastLat, lon = $lastLon,扫描到${yaolingList.length}只稀有');
        if (!isPause) {
          onReceiveData(yaolingList);
        }
      }

      print('经度差别：${maxLon - minLon}，维度差别：${maxLat - minLat}');

      if (!isPause) {
        // 没有暂停，继续扫描
        // 计算���一次扫描经度，维度不变
        var nextLat = lastLat;
        var nextLon = lastLon + (maxLon - minLon) + 1;
        if (nextLat >= MIN_LAT &&
            nextLat <= MAX_LAT &&
            nextLon >= MIN_LON &&
            nextLon <= MAX_LON) {
          // 在区域内

          // Future.delayed(Duration(seconds: delayTime), () {
          scanning(nextLat, nextLon);
          // });
        } else {
          // 在区域外,就增加维度，还原经度
          nextLat = lastLat + (maxLat - minLat) + 1;
          nextLon = MIN_LON;
          if (nextLat > MIN_LAT && nextLat < MAX_LAT) {
            // 在区域内，扫描
            // Future.delayed(Duration(seconds: delayTime), () {
            scanning(nextLat, nextLon);
            // });
          } else {
            // 不在，说明扫描��束了，停止递归
            isPause = true;
            onReceiveData(null);
            print('超出范围，扫描终止');
          }
        }
      }
    }
  }

  /// 经纬度转换成int
  int convertLocation(double number) {
    return int.parse((number * 1e6).toStringAsFixed(0));
  }

  /// int转换成经纬度
  double convertToLocation(int number) {
    return number / 1e6;
  }

  /// 写入数据
  void write(String content) async {
    print('写入数据：$content');
    if (socket == null || !isConnect) {
      print('已断开连接，无法写入数据');
    } else {
      Uint8List result = Uint8List(4 + content.length);
      Uint8List head = Uint8List(4);
      ByteData.view(head.buffer).setUint32(0, content.length);
      result.setAll(0, head);
      result.setAll(4, content.codeUnits);
      // print('content length = ${content.length}');
      // print('发送数据$result');
      socket.add(result);
    }
  }

  void errorHandler(error) {
    print('连接异常：$error');
    if (!isPause) {
      onConnect(0);
    }
    isConnect = false;
    socket.close();
    socket = null;
  }

  void doneHandler() {
    print('socket is done.');
    if (!isPause) {
      onConnect(0);
      socket.close();
      socket = null;
    }

    isConnect = false;
  }
}
