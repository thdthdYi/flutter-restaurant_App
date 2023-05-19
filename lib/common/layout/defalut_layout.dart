import 'package:flutter/material.dart';

class DefalutLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  final String? title;
  final Widget? bottomNavigationBar;

  const DefalutLayout(
      {required this.child,
      this.backgroundColor,
      Key? key,
      this.title,
      this.bottomNavigationBar})
      : super(key: key);

//모든 view에 적용하고 싶은 Layout을 이곳에 적용하면 됌.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: renderAppBar(),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar? renderAppBar() {
    if (title == null) {
      return null;
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title!,
          style: TextStyle(fontSize: 16.0),
        ),
        foregroundColor: Colors.black,
      );
    }
  }
}
