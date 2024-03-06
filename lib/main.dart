import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:example/notification_controller.dart';

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await initializeService();
  final service = FlutterBackgroundService();

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'comments channel',
        channelName: 'kCommentChannelName',
        channelDescription: 'teacher reply',
        channelGroupKey: 'key1'),
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: 'key1', channelGroupName: 'kCommentGroupName')
  ]);
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  service.startService();

  runApp(const MyApp());
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Timer.periodic(const Duration(seconds: 10), (timer) {
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //         id: 10,
  //         channelKey: 'comments channel',
  //         title: 'jsonData[' ']',
  //         body: 'jsonData[' ']'),
  //   );
  // });

//   Some code for background task
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "App in background...",
        content: "Update ${DateTime.now()}",
      );
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'comments channel',
            title: 'jsonData[' ']',
            body: 'jsonData[' ']'),
      );
    }
    service.invoke(
      'update',
      {"current_date": DateTime.now().toIso8601String()},
    );
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'comments channel',
          title: 'jsonData[' ']',
          body: 'jsonData[' ']'),
    );
  });
}

//THANKS GODDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
