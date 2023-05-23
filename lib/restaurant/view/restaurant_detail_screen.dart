import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/dio/dio.dart';

import 'package:flutter_new_project/common/layout/defalut_layout.dart';
import 'package:flutter_new_project/common/secure_storage/secure_storage.dart';
import 'package:flutter_new_project/restaurant/component/retaurant_card.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_new_project/restaurant/provider/restaurant_provider.dart';
import 'package:flutter_new_project/restaurant/rating/rating_card.dart';
import 'package:flutter_new_project/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletons/skeletons.dart';

import '../../common/const/data.dart';
import '../../product/component/product_card.dart';
import '../model/restaurant_model.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const RestaurantDetailScreen({required this.id, Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);
  }

  ///provier로 코드 간략화 하기
// //받는 형식을 맞게 바꿔줘야 함.
  ///   Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
  ///     return ref.watch(RestaurantRepositoryProvider).getRestaurantDetail(id: id);

  // //Appbuilder시 dioProvider
  // final dio = ref.watch(dioProvider);

  // final repository =
  //     RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

  // return repository.getRestaurantDetail(id: id);

  // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

  // final resp = await dio.get('http://$ip/restaurant/$id',
  //     options: Options(headers: {
  //       'authorization': 'Bear $accessToken',
  //}

  // ));

  // return resp.data;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));

    if (state == null) {
      return const DefalutLayout(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }

    return DefalutLayout(
        title: '불타는 떡볶이',
        child: CustomScrollView(
          slivers: [
            renderTop(model: state),
            if (state is! RestaurantDetailModel) renderLoading(),
            if (state is RestaurantDetailModel) renderLabel(),
            if (state is RestaurantDetailModel)
              rederProducts(
                products: state.products,
              ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: RatingCard(
                  avatarImage:
                      AssetImage('asset/img/logo/codefactory_logo.png'),
                  content: 'good',
                  email: 'js@factory.ai',
                  images: [],
                  rating: 4,
                ),
              ),
            )
          ],
        ));
  }

  SliverPadding renderLoading() {
    return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        sliver: SliverList(
            delegate: SliverChildListDelegate(List.generate(
                3,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: SkeletonParagraph(
                        style: SkeletonParagraphStyle(
                            lines: 5, padding: EdgeInsets.zero),
                      ),
                    )))));
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

  SliverToBoxAdapter renderTop({required RestaurantModel model}) {
    return SliverToBoxAdapter(
        child: RestaurantCard.fromModel(
      model: model,
      isDetail: true,
    ));
  }
}
