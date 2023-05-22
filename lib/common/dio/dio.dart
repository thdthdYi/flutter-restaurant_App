import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES]] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

//3) error

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      return handler.reject(err);
    }

    //해당 서버에서 토큰이 잘 못 됐다는 에러 상태.
    final isStatus401 = err.response?.statusCode == 401; //에러코드 확인
    final isPathRefresh =
        err.requestOptions.path == 'quth/token'; //refresh token err인지 확인
    //refresh token 자체에 문제가 있음.

    //토큰 재발급 시도
    if (isStatus401 && isPathRefresh) {
      final dio = Dio();
      try {
        final resp = await dio.post('http://$ip/auth/token',
            options:
                Options(headers: {'authorization': 'Bearer $refreshToken'}));
        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        //토큰 변경
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });
        //storage에서 가져올 때마다 새로 발급된 accessToken을 가져옴.
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        //요청재전송
        final response = await dio.fetch(options);

        //새로 보낸 요청에 대한 응답
        return handler.resolve(response);
      }

      //refresh token을 할 수 없음
      on DioError catch (e) {
        return handler.reject(e); //그대로 에러 반환
      }
    }

    return handler.reject(err);
  }
}
