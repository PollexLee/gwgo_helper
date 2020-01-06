import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gwgo_helper/core/socket_core.dart';
import 'package:gwgo_helper/core/websocket_callback.dart';
import 'package:gwgo_helper/model/yaoling.dart';

// main(List<String> args) {
//   YaolingInfoManager().init();
// }

class YaolingInfoManager implements Callback {
  WebSocketCore socketCore;
  Dio dio = Dio();
  // static YaolingInfo yaolingInfo;
  static Map<int, Yaoling> yaolingMap;

  init() {
    // socketCore = WebSocketCore();
    // socketCore.init(1, (int status) {
    //   if (status == 0) {
    //     updateYaolingConfig();
    //   }
    //   print('socketCore.init status = $status');
    // });

    updateYaolingConfig();
  }

  /// 更新妖灵配置信息
  updateYaolingConfig() {
    /// 组建上传参数
    // Map<String, dynamic> map = HashMap();
    // JsonCodec jsonCodec = JsonCodec();
    // map['request_type'] = '1004';
    // int requestid = int.parse(
    //     DateTime.now().millisecondsSinceEpoch.toString().substring(8));
    // map['requestid'] = requestid;
    // map['platform'] = 0;
    // map['cfg_type'] = 0;
    // map['gwgo_token'] = '8517517354590437376';
    // map['appid'] = 'wx19376645db21af08';
    // map['openid'] = 'oxARK5HjVuWCPRfcpRa4EIY9J96c';
    // socketCore.send(requestid, jsonCodec.encode(map), this);

    // 获取配置的wss请求无效了，我们使用以前的一个配置文件
    onReceiveData(null);
  }

  @override
  onError(int code) {
    return null;
  }

  @override
  onReceiveData(Map<String, dynamic> data) {
    // print(data);
    // socketCore.close();
    // String filename = data['filename'];
    // sprite_f9e4d4876d5ac919bfc12b4a316d9d05.json
    // 日期
    String filename = 'sprite_8c805b2c6bbe4af4ad66931dc1a68f98.json';
    print('filename = $filename');
    Future<Response> response =
        dio.get('https://hy.gwgo.qq.com/sync/pet/config/$filename');
    response.then((response) {
      print(response.data.runtimeType);
      YaolingInfo yaolingInfo = YaolingInfo.fromJson(response.data);
      if (null != yaolingInfo.yaolingList &&
          yaolingInfo.yaolingList.isNotEmpty) {
        yaolingMap = Map();
        yaolingInfo.yaolingList.forEach((item) {
          item.SmallImgPath = '${yaolingInfo.Url}${item.SmallImgPath}';
          item.BigImgPath = '${yaolingInfo.Url}${item.BigImgPath}';
          yaolingMap[item.Id] = item;
        });
      }
    });

    return null;
  }

  /// 获取妖灵名称
  static String getYaolingName(int id) {
    if (id == 2200267) {
      return '香奴儿';
    }
    if (yaolingMap[id] == null) {
      return "未知";
    }
    return yaolingMap[id].Name;
  }
}
