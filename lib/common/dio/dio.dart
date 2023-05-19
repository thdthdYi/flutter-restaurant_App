import 'package:dio/dio.dart';
import 'package:flutter_new_project/common/const/data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

//1) request
/*
요청이 보내질 때마다 요청의 Header- accessToken : true라는 값이 있으면
실제 토큰을 storage에서 가져와서 authorization : bearer $token으로 헤더를 변경.
 */
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ]] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      //delete header
      options.headers.remove('acceessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      //replace header
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      //delete header
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      //replace header
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }
    return super.onRequest(options, handler);
  }

//2) response
//3) error
}
