import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'package:star23sharp/main.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/services/index.dart';

//포그라운드로 알림을 받아서 알림을 탭했을 때 페이지 이동
@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse notificationResponse) {
  try {
    // 데이터에서 notificationId 추출
    final payload = notificationResponse.payload;
    final Map<String, dynamic> parsedPayload =
        payload != null ? jsonDecode(payload) : {};
    final notificationId = parsedPayload['notificationId'];

    if (notificationId != null) {
      AppGlobal.navigatorKey.currentState!.pushNamed(
        '/notification',
        arguments: int.tryParse(notificationId), // notificationId를 전달
      );
    } else {
      logger.e("Notification ID is missing in the payload.");
    }
  } catch (e) {
    logger.e("Failed to parse notification payload: $e");
  }
}
// @pragma('vm:entry-point')
// void onNotificationTap(NotificationResponse notificationResponse) {
//   AppGlobal.navigatorKey.currentState!
//       .pushNamed('/notification', arguments: notificationResponse);
// }

class FCMService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _token;
  //권한 요청
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    try {
      _token = await FirebaseMessaging.instance.getToken();
      logger.d("내 디바이스 토큰: $_token");
    } catch (e) {
      logger.e("Error getting token: $e");
    }
  }

  //flutter_local_notifications 패키지 관련 초기화
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  //포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('pomo_timer_alarm_1', 'pomo_timer_alarm',
            channelDescription: '',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

//포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showImageNotification({
    required String title,
    required String body,
    required String imageUrl,
    required String payload,
  }) async {
    final localImagePath = await FCMService.downloadImage(imageUrl);
    logger.d('Image downloaded to: $localImagePath');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(localImagePath), // 이미지 경로
      largeIcon: FilePathAndroidBitmap(localImagePath),
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'image_channel', // 채널 ID
      'Image Notifications', // 채널 이름
      channelDescription: 'Channel for image notifications',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // 이미지 다운로드 함수
  static Future<String> downloadImage(String imageUrl) async {
    try {
      final dio = DioService.dio;
      final documentDirectory = (await getApplicationDocumentsDirectory()).path;
      final filePath = '$documentDirectory/notification_image.jpg';

      // 이미지 다운로드
      await dio.download(
        imageUrl, // 다운로드 URL
        filePath, // 저장할 파일 경로
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // 다운로드 진행 상황 출력 (선택사항)
            print(
                'Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return filePath; // 다운로드된 파일 경로 반환
    } catch (e) {
      throw Exception('Image download failed: $e');
    }
  }
  // //API를 이용한 발송 요청
  // static Future<void> send(
  //     {required String title, required String message}) async {
  //   final jsonCredentials =
  //       await rootBundle.loadString('assets/data/firebaseAuth.json');
  //   final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
  //   final client = await auth.clientViaServiceAccount(
  //     creds,
  //     ['https://www.googleapis.com/auth/cloud-platform'],
  //   );

  //   final notificationData = {
  //     'message': {
  //       'token': _token, //기기 토큰
  //       'data': {
  //         //payload 데이터 구성
  //         'via': 'FlutterFire Cloud Messaging!!!',
  //       },

  //       'notification': {
  //         'title': title, //푸시 알림 제목
  //         'body': message, //푸시 알림 내용
  //       }
  //     },
  //   };
  //   final fcmKey = dotenv.env['FCM_ADMIN_KEY'].toString();
  //   final response = await client.post(
  //     Uri.parse('https://fcm.googleapis.com/v1/projects/$fcmKey/messages:send'),
  //     headers: {
  //       'content-type': 'application/json',
  //     },
  //     body: jsonEncode(notificationData),
  //   );

  //   client.close();
  //   if (response.statusCode == 200) {
  //     debugPrint(
  //         'FCM notification sent with status code: ${response.statusCode}');
  //   } else {
  //     debugPrint(
  //         '${response.statusCode} , ${response.reasonPhrase} , ${response.body}');
  //   }
  // }
}
