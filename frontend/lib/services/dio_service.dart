import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/utilities/app_global.dart';

class DioService {
  static String baseUrl = dotenv.env['API_URL'].toString();          

  // Private constructor to prevent instantiation
  DioService._internal();

  // 기본 Dio 인스턴스
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10), // 연결 시간
      receiveTimeout: const Duration(seconds: 10), // 응답 시간
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Authorization 헤더와 인터셉터가 추가된 Dio 인스턴스
  static final Dio authDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 전 처리 (예: 토큰 갱신)
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 후 처리
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          logger.d('Error: ${e.message}');

          if (e.response?.statusCode == 401) {
            // 토큰 만료 시 갱신 로직 수행
            final authProvider = Provider.of<AuthProvider>(
              AppGlobal.navigatorKey.currentContext!,
              listen: false,
            );

            // 새로운 토큰을 얻기 위한 시도
            final newToken = await authProvider.refreshTokens();
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final cloneReq = await authDio.fetch(e.requestOptions);
              return handler.resolve(cloneReq); // 재요청 결과 반환
            }else{
              
            }
          }

          return handler.next(e);
        },
      ),
    );

  // Authorization 토큰을 업데이트하는 메서드
  static void updateAuthorizationHeader(String token) {
    logger.d(token);
    authDio.options.headers['Authorization'] = 'Bearer $token';
  }
}
