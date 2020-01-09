
import 'package:gwgo_helper/config.dart' as config;

class TokenModel {
  String token;
  String code;
  String openid;

  TokenModel({this.token, this.code, this.openid});

  TokenModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    code = json['code'];
    openid = json['openid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['code'] = this.code;
    data['openid'] = this.openid;
    return data;
  }

  /// 将当前token发布到公共配置文件中
  publish() {
    config.token = token;
    config.openid = openid;
  }
}
