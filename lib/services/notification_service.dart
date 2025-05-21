import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'permission_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final _permissionService = PermissionService();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    // Vérifier et demander la permission si nécessaire
    final hasPermission = await _permissionService.requestNotificationPermission();
    if (!hasPermission) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool playSound = true,
    bool vibrate = true,
  }) async {
    // Vérifier la permission avant d'afficher la notification
    final hasPermission = await _permissionService.checkNotificationPermission();
    if (!hasPermission) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'fintech_channel',
      'Fintech Notifications',
      channelDescription: 'Notifications pour les transactions Fintech',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
