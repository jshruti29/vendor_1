// ignore_for_file: prefer_const_constructors
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:vendor_1/model/notification_badge.dart';
import 'package:vendor_1/model/pushnotification_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounterCounter;
  pushnotificationModel? _notificateInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted the permission");
    } else {
      print("permission declined by the user");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      pushnotificationModel notification = pushnotificationModel(
        title: message.notification!.title,
        body: message.notification!.body,
        dataTitles: message.data['Title'],
        dataBody: message.data['Body'],
      );

      setState(() {
        _totalNotificationCounterCounter++;
        _notificateInfo = notification;
      });

      if (notification != null) {
        showSimpleNotification(Text(_notificateInfo!.title!),
            leading: NotificationBadge(
                totalNotification: _totalNotificationCounterCounter),
            subtitle: Text(_notificateInfo!.body!),
            background: Colors.deepOrangeAccent,
            duration: Duration(seconds: 4));
      }
    });
  }

  @override
  void initState() {
    registerNotification();
    // TODO: implement initState
    _totalNotificationCounterCounter = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PushNotification"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "FutterPushNotification",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            NotificationBadge(
                totalNotification: _totalNotificationCounterCounter),
            _notificateInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text(
                            "TITLE : ${_notificateInfo!.dataTitles ?? _notificateInfo!.title}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 9),
                        Text(
                            "TITLE : ${_notificateInfo!.dataBody ?? _notificateInfo!.body}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ])
                : Container()
          ],
        ),
      ),
    );
  }
}
