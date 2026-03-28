import 'package:package_info_plus/package_info_plus.dart';

enum AppFlavor { free, paid }

class ConfigProvider {
  static late PackageInfo packageInfo;
  static AppFlavor get flavor {
    final packageName = packageInfo.packageName;
    if (packageName.endsWith('.free')) {
      return AppFlavor.free;
    } else {
      return AppFlavor.paid;
    }
  }

  static bool get isFree => flavor == AppFlavor.free;
  static bool get isPaid => flavor == AppFlavor.paid;

  static Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}
