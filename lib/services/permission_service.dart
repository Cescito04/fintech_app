import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  Future<bool> requestNotificationPermission() async {
    // Sur Android 13 et plus, on demande la permission POST_NOTIFICATIONS
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> checkNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      return false;
    }
    return true;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
