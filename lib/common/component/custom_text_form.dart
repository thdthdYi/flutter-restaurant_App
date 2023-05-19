import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/const/color.dart';

//TextFormField 디자인
class CustomTextFormField extends StatelessWidget {
  //외부에서 받아오기
  final String? hinttext;
  final String? errortext;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  //외부에서 따로 정해줄 항목들

  const CustomTextFormField(
      {required this.onChanged,
      this.obscureText = false,
      this.autofocus = false,
      this.hinttext,
      this.errortext,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //textformfeild border
    const baseBorder = OutlineInputBorder(
        borderSide:
            BorderSide(color: Color.fromARGB(255, 222, 221, 221), width: 1.0));
    return TextFormField(
      cursorColor: PRIMARY_COLOR,
      obscureText: obscureText, //비밀번호 입력 시
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          hintText: hinttext,
          errorText: errortext,
          hintStyle: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0),
          fillColor: INPUT_BG_COLOR,
          filled: true,
          //모든 input 상태의 기본 스타일 세팅
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: baseBorder.copyWith(
              borderSide:
                  baseBorder.borderSide.copyWith(color: PRIMARY_COLOR))),
    );
  }
}
