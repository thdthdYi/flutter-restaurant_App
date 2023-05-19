import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/const/color.dart';
import 'package:flutter_new_project/common/layout/defalut_layout.dart';

import '../../restaurant/view/restaurant_screen.dart';

class RootTab extends StatefulWidget {
  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;

  int index = 0;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 4, vsync: this); //this > state

    //controller에서 값이 변경될 때마다 특정 변수 실행
    controller.addListener(tabListner);
  }

  void dispose() {
    controller.removeListener(tabListner);

    super.dispose();
  }

  void tabListner() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefalutLayout(
      title: '딜리버리',
      // ignore: sort_child_properties_last
      child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [
            RestaurantScreen(),
            Center(
              child: Text('음식'),
            ),
            Center(
              child: Text('주문'),
            ),
            Center(
              child: Text('프로필'),
            )
          ]),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: PRIMARY_COLOR,
          unselectedItemColor: BODY_TEXT_COLOR,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.shifting, //선택할때마다 탭이 살짝 커짐
          onTap: (int index) {
            controller.animateTo(index);
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fastfood_outlined), label: '음식'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_outlined), label: '주문'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined), label: '프로필'),
          ]),
    );
  }
}
