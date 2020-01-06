class PromiseModel {
  String qrCodeimageUrl;
  String invalidTime;
  String codeName;

  PromiseModel({this.qrCodeimageUrl, this.invalidTime, this.codeName});

  PromiseModel.fromJson(Map<String, dynamic> json) {
    qrCodeimageUrl = json['qrCodeimageUrl'];
    invalidTime = json['invalidTime'];
    codeName = json['codeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['qrCodeimageUrl'] = this.qrCodeimageUrl;
    data['invalidTime'] = this.invalidTime;
    data['codeName'] = this.codeName;
    return data;
  }
}


class RequestPromiseModel {
  String imei;
  String code;

  RequestPromiseModel({this.imei, this.code});

  RequestPromiseModel.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imei'] = this.imei;
    data['code'] = this.code;
    return data;
  }
}
