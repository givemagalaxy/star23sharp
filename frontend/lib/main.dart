import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';

//TODO - 카카오 연결
//TODO - 카메라 연결

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    print("Notification Received!");
  }
}

//푸시 알림 메시지와 상호작용을 정의합니다.
Future<void> setupInteractedMessage() async {
  //앱이 종료된 상태에서 열릴 때 getInitialMessage 호출
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  //앱이 백그라운드 상태일 때, 푸시 알림을 탭할 때 RemoteMessage 처리
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

//FCM에서 전송한 data를 처리합니다. /message 페이지로 이동하면서 해당 데이터를 화면에 보여줍니다.
void _handleMessage(RemoteMessage message) {
  Future.delayed(const Duration(seconds: 1), () {
    print("알림 페이지로 이동!!!!!");
    AppGlobal.navigatorKey.currentState!
        .pushNamed("/notification", arguments: message);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env/.env");

  final appKey = dotenv.env['APP_KEY'] ?? '';
  AuthRepository.initialize(
    appKey: appKey,
  );

//firebase setting
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //FCM 푸시 알림 관련 초기화
  PushNotification.init();
  //flutter_local_notifications 패키지 관련 초기화
  PushNotification.localNotiInit();
  //백그라운드 알림 수신 리스너
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //포그라운드 알림 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
          ),
        ),
      );
    }
  });
  //메시지 상호작용 함수 호출
  setupInteractedMessage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: AppGlobal.navigatorKey,
      theme: ThemeData(
          primaryColor: themeProvider.backgroundColor,
          fontFamily: 'Hakgyoansim Chilpanjiugae'),
      navigatorObservers: <NavigatorObserver>[observer],
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MainLayout(child: HomeScreen()),
        '/map': (context) => const MainLayout(child: MapScreen()),
        '/starstorage': (context) => MainLayout(child: StarStoragebox()),
        '/starwriteform': (context) =>
            const MainLayout(child: StarFormScreen()),
        '/profile': (context) => const MainLayout(child: ProfileScreen()),
        '/notification': (context) =>
            const MainLayout(child: PushAlarmScreen()),
        '/signin': (context) => const MainLayout(child: LoginScreen()),
        '/signup': (context) => const MainLayout(child: SignUpScreen()),

        // '/loading': (context) => const MainLayout(child: LoadingScreen()),
      },
    );
  }
}
