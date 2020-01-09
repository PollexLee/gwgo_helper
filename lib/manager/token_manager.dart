import 'package:dio/dio.dart';
import 'package:gwgo_helper/model/token_model.dart';

Dio dio = MyDio();

class TokenManager {
  // 启动妖灵扫描的时候，获取token
  static Future getTokenForYaoling() async {
    // 请求接口获取token
    print('getTokenForYaoling');
    Response response = await dio.get('/getTk');
    return TokenModel.fromJson(response.data);
  }

  static Future releaseToken(String token) async {
    print('releaseToken = $token');
    await dio.get('/releaseTk', queryParameters: {'token': token});
  }

  static Future deleteToken(String token) async {
    print('deleteToken = $token');
    await dio.get('/deleteTk', queryParameters: {'token': token});
  }

  /// 启动擂台扫描的时候，获取token
  static Future getTokenForLeitai() async {
    return null;
  }
}

class MyDio extends Dio {
  MyDio() {
    options.baseUrl = "http://gwgo.pollex.me:8848";
    // options.baseUrl = "http://10.26.28.47:8848";
    options.headers.addAll({'Content-Type': 'application/json'});
    options.connectTimeout = 20000;
    options.receiveTimeout = 20000;
  }
}
