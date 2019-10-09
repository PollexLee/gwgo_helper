class DeviceInfo {
  String imei;
  int createTime;
  int updateTime;
  int expireTime;
  String device;
  int sdkVersion;
  String version;
  String token;
  String openid;

  DeviceInfo(
      {this.imei,
      this.createTime,
      this.updateTime,
      this.expireTime,
      this.device,
      this.sdkVersion,
      this.version,
      this.token,
      this.openid});

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
        imei: json['imei'],
        createTime: json['createTime'],
        updateTime: json['updateTime'],
        expireTime: json['expireTime'],
        device: json['device'],
        sdkVersion: json['sdkVersion'],
        version: json['version'],
        token: json['token'],
        openid: json['openid']);
  }
}
