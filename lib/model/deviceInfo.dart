class DeviceInfo {
  String imei;
  int createTime;
  int updateTime;
  int expireTime;
  String device;
  int sdkVersion;
  String version;

  DeviceInfo(
      {this.imei,
      this.createTime,
      this.updateTime,
      this.expireTime,
      this.device,
      this.sdkVersion,
      this.version});

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      imei: json['imei'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      expireTime: json['expireTime'],
      device: json['device'],
      sdkVersion: json['sdkVersion'],
      version: json['version'],
    );
  }
}
