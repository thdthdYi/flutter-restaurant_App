import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_new_project/common/const/color.dart";
import "package:flutter_new_project/common/layout/defalut_layout.dart";
import "package:flutter_new_project/common/secure_storage/secure_storage.dart";
import 'package:flutter_new_project/user/view/login_screen.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../../common/const/data.dart';
import "../../common/view/root_tab.dart";

//프로그램 빌드 시 로딩 화면
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkToken();
  }

  void checkToken() async {
    final storage = ref.read(secureStorageProvider);
    //Token 불러오기
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY); //유효기간 1일
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY); //유효기간 5분

    final dio = Dio();

//token 발급
    try {
      //Token refresh 적용법
      //storage refreshToken을 기반으로 accessToken 발급
      final resp = await dio.post('http://$ip/auth/token',
          options: Options(headers: {
            'authorization': 'Bearer $refreshToken',
          }));

      await storage.write(
          key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);

      //Token 여부 검증
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RootTab(),
        ),
        (route) => false,
      );
    } catch (e) {
      //token 검증에서 문제가 생기면 login 화면으로 넘어감
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  void deleteToken() async {
    final storage = ref.read(secureStorageProvider);

    await storage.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return DefalutLayout(
        backgroundColor: PRIMARY_COLOR,
        child: SizedBox(
          //넓이 최대 > 가운데 정렬
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/img/logo/logo.png',
                width: MediaQuery.of(context).size.width / 2,
              ),
              const SizedBox(
                height: 16.0,
              ),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ],
          ),
        ));
  }
}
