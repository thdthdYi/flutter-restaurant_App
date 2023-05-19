import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/const/color.dart';
import 'package:flutter_new_project/common/const/data.dart';

import '../../component/custom_text_form.dart';
import '../../layout/defalut_layout.dart';
import 'package:dio/dio.dart';

import '../../view/root_tqb.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    //storage open > 프로그램 빌드할 때마다 로그인이 풀리는 것을 방지

    final dio = Dio();

    return DefalutLayout(
      //키보드가 올라왔을 때 뒤 기본 스크린을 스크롤 가능
      child: SingleChildScrollView(
        //drag로 키보드 숨기기 가능
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                const _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hinttext: '이메일을 입력해주세요.',
                  onChanged: (String value) {
                    username = value;
                  },
                ),
                const SizedBox(
                  height: 8.0,
                ),
                CustomTextFormField(
                  hinttext: '비밀번호을 입력해주세요.',
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //----------------로그인 구현 기본 흐름 ---------------------
                    //ID:비밀번호
                    final rawString = '$username:$password';

                    /*
                    //Id:비밀번호 해당 String을 Base64로 인코딩하여 넣어야함
                    final rawString = 'test@codefactory.ai:testtest';*/

                    //일반 String을 Base64로 바꿈
                    Codec<String, String> stringToBase64 = utf8.fuse(base64);

                    //rawString encode
                    String token = stringToBase64.encode(rawString);

                    //로그인버튼을 누르면 해당 아이피로 요청
                    final resp = await dio.post('http://$ip/auth/login',
                        options: Options(
                            headers: {'authorization': 'Basic $token'}));

                    //resp에서 token 가져오기
                    final refreshToken = resp.data['refreshToken'];
                    final accessToken = resp.data['accessToken'];

                    //저장소에 값 넣어주기
                    await storage.write(
                        key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(
                        key: ACCESS_TOKEN_KEY, value: accessToken);

                    //토큰 인증이 되면 다음 화면으로 넘어감
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RootTab(),
                      ),
                    );

                    //refresh Token, access Token > resp body
                    print(resp.data);
                  },
                  //----------------------------------------------------------
                  child: Text('로그인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                ),
                /*            
                TextButton(
                  onPressed: () async {
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Text('회원가입'),
                )*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      "환영합니다!",
      style: TextStyle(
          fontSize: 34.0, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      "이메일과 비밀번호를 입력해서 로그인해주세요! \n오늘도 성공적인 주문이 되길 :)",
      style: TextStyle(fontSize: 16.0, color: BODY_TEXT_COLOR),
    );
  }
}
