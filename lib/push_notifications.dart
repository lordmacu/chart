

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const MethodChannel _channel =
  MethodChannel('shiba.io/all');


  Map<String, String> channelMap = {
    "id": "CHAT_MESSAGES",
    "name": "Chats",
    "description": "Chat notifications",
  };

  void _createNewChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);

    } on PlatformException catch (e) {

      print(e);
    }
  }


  Future onSelectNotification(String payload) {


    print("est ees el payload  ${payload}");
  }

  showNotification(title,description) async {
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, title, description, platform,
        payload: 'Welcome to the Local Notification demo');
  }
Future subscribe(){
  _fcm.subscribeToTopic('all');
}

  Future unSubscribe(){
    _fcm.unsubscribeFromTopic('all');
  }
  Future initialise() async {



    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher_foreground');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    _createNewChannel();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
       showNotification(message["notification"]["title"],message["notification"]["body"]);
        print("onMessage: ${message["notification"]}]");

      },
      onLaunch: (Map<String, dynamic> message) async {
        showNotification(message["notification"]["title"],message["notification"]["body"]);

        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        showNotification(message["notification"]["title"],message["notification"]["body"]);

        print("onResume: $message");
      },
    );
  }
}