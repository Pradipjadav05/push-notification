import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

// for flutter_local_notifications

class NotificationService {

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    await Permission.notification.status.isDenied.then((value) {
      if(value){
        Permission.notification.request();
      }
    });

    await Permission.scheduleExactAlarm.status.isDenied.then((value) {
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

    tz.initializeTimeZones();

    await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {});
  }



  Future<NotificationDetails> _notificationDetails() async {
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

    return notificationDetails;
  }

  Future showNotification({int id = 0, String title ="message.notification!.title", String body = "message.notification!.body", String? payLoad}) async {

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    notificationsPlugin.show(
      notificationId,
      title,
      body,
      await _notificationDetails(),
    );

    // return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> showScheduleNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {

    final details = await _notificationDetails();
    await notificationsPlugin.zonedSchedule(
      id,
      "$title $id",
      body,
      tz.TZDateTime.from(
          DateTime.now().add(Duration(seconds: seconds)), tz.local),
      details,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // it is for periodically notification
  Future<void> showPeriodicallyNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await notificationsPlugin.periodicallyShow(
      id,
      "$title $id",
      body,
      RepeatInterval.everyMinute,
      details,
    );
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

}

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