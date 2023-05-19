import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_new_project/common/const/data.dart';
import 'package:flutter_new_project/restaurant/component/retaurant_card.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_model.dart';
import 'package:flutter_new_project/restaurant/view/restaurant_detail_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List> paginateRestaurant() async {
    final dio = Dio();

    //storage에서 accesstoken 가져오기
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    //restaurant url에 accesstoken을 넣어 요청 보내기
    final resp = await dio.get('http://$ip/restaurant',
        options: Options(headers: {
          'authorization': 'Bearer $accessToken',
        }));
    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List>(
              future: paginateRestaurant(),
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      final item = snapshot.data![index];

                      final pItem = RestaurantModel.fromJson(json: item);

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                RestaurantDetailScreen(id: pItem.id),
                          ));
                        },
                        child: RestaurantCard.fromModel(model: pItem),
                      );
                    },
                    separatorBuilder: (_, index) {
                      return const SizedBox(
                        height: 16.0,
                      );
                    });
              })),
    ));
  }
}
