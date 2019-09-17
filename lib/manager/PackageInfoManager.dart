import 'package:package_info/package_info.dart';

class PackageInfoManager {
  static var packageVersion = '';

  static void init() {
    Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
    packageInfo.then((info) {
      packageVersion = info.version;
    });
  }
}
