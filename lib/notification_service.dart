import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

// for flutter_local_notifications

/*class NotificationService {

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    await Permission.notification.status.isDenied.then((value) {
      if(value){
        Permission.notification.request();
      }
    });

    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {});
  }




  Future showNotification({int id = 0, String? title, String? body, String? payLoad}) async {

    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      "High Importance Notification",
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('sample9s'),
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      importance: Importance.high,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    notificationsPlugin.show(
      notificationId,
      "message.notification!.title",
      "message.notification!.body",
      notificationDetails,
    );

    // return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  // initialize firebase notification service
  void firebaseNotification(context) {

    // call initialize local notification
    initNotification();


    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) async {
      await showNotification(body: message.toString());
    });
  }

  // get the token of FirebaseMessaging and save into users collection
  Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
  }

}*/

class NotificationServiceChannel {

  static const MethodChannel _channel = MethodChannel('somethinguniqueforyou.com/channel_test');

  Future<void> initNotification(String message) async {
    await Permission.notification.status.isDenied.then((value) {
      if(value){
        Permission.notification.request();
      }
    });

    try {
      // generate id for unique notification
      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      Map<String, String> channelMap = {
        "id": notificationId.toString(),
        "name": "Custom channel Notification",
        "description": message,
      };

      await _channel.invokeMethod('createNotificationChannel', channelMap);

    } on PlatformException catch (e) {
      print(e);
    }
  }

  // used te request permission for notification
  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

}