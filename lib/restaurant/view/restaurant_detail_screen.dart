import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/dio/dio.dart';

import 'package:flutter_new_project/common/layout/defalut_layout.dart';
import 'package:flutter_new_project/restaurant/component/retaurant_card.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_new_project/restaurant/repository/restaurant_repository.dart';

import '../../common/const/data.dart';
import '../../product/component/product_card.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;

  const RestaurantDetailScreen({required this.id, Key? key}) : super(key: key);

//받는 형식을 맞게 바꿔줘야 함.
  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(
        storage: storage,
      ),
    );

    final repository =
        RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(id: id);

    // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    // final resp = await dio.get('http://$ip/restaurant/$id',
    //     options: Options(headers: {
    //       'authorization': 'Bear $accessToken',
  }

  // ));

  // return resp.data;
  @override
  Widget build(BuildContext context) {
    return DefalutLayout(
        title: '불타는 떡볶이',
        child: FutureBuilder<RestaurantDetailModel>(
            future: getRestaurantDetail(),
            builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //snapshot에서 mapping된 item을 얻을 수 있기 때문에 더이상 필요없음.
              // final item = RestaurantDetailModel.fromJson(
              //   snapshot.data!,
              // );

              return CustomScrollView(
                slivers: [
                  renderTop(model: snapshot.data!),
                  renderLabel(),
                  rederProducts(
                    products: snapshot.data!.product,
                  )
                ],
              );
            }));
  }

  SliverPadding renderLabel() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
          child: Text(
        '메뉴',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      )),
    );
  }

  SliverPadding rederProducts({
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];

            return Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ProductCard.fromModel(
                model: model,
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantDetailModel model}) {
    return SliverToBoxAdapter(
        child: RestaurantCard.fromModel(
      model: model,
      isDetail: true,
    ));
  }
}
