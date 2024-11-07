import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    logger.d("Notification Received!");
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

void _handleMessage(RemoteMessage message) {
  logger.d("Handling message: $message");
  // 데이터에서 notificationId 추출
  final notificationId = message.data['notificationId'];

  Future.delayed(const Duration(seconds: 1), () {
    if (notificationId != null) {
      AppGlobal.navigatorKey.currentState!.pushNamed(
        "/notification",
        arguments: int.tryParse(notificationId), // notificationId를 전달
      );
    } else {
      logger.e("Notification ID is missing in the message data.");
    }
  });
}

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // 호출 스택 깊이
    errorMethodCount: 5, // 에러 발생 시 호출 스택 깊이
    lineLength: 50, // 한 줄의 길이 제한
    colors: true, // 컬러 출력 여부
    printEmojis: true, // 이모지 출력 여부
  ),
);

// 토큰 저장 관련
const storage = FlutterSecureStorage();

// storage에 저장해둔 내용 받아오기
Future<void> loadAccessToken(AuthProvider authProvider) async {
  String? access = await storage.read(key: 'access');
  String? refresh = await storage.read(key: 'refresh');
  if (access != null && refresh != null) {
    logger.d("access: $access, refresh: $refresh");
    authProvider.setToken(access, refresh);
  } else {
    logger.d("토큰 없음 -> 로그인 안된 상태");
  }
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
  FCMService.init();
  //flutter_local_notifications 패키지 관련 초기화
  FCMService.localNotiInit();
  //백그라운드 알림 수신 리스너
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //포그라운드 알림 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    String? imageUrl = message.notification?.android?.imageUrl;
    logger.d("Handling message: $message");
    if (notification != null) {
      if (imageUrl != null) {
        // 이미지가 포함된 경우
        await FCMService.showImageNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          imageUrl: imageUrl,
          payload: jsonEncode(message.data),
        );
      } else {
        // 일반 알림
        await FCMService.showSimpleNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    }
  });

  //메시지 상호작용 함수 호출
  setupInteractedMessage();

  // env 파일 설정
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageFormProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
        '/message_style_editor': (context) =>
            const MainLayout(child: ChooseStarStyleScreen()),
        '/stardetail': (context) => const MainLayout(child: StarDetailScreen()),
        // '/loading': (context) => const MainLayout(child: LoadingScreen()),
      },
    );
  }
}
