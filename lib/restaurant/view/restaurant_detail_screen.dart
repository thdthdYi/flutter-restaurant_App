import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;

import 'package:flutter_new_project/common/layout/defalut_layout.dart';

import 'package:flutter_new_project/restaurant/component/retaurant_card.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_new_project/restaurant/provider/restaurant_provider.dart';
import 'package:flutter_new_project/rating/rating_card.dart';
import 'package:flutter_new_project/restaurant/provider/restaurant_rating_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skeletons/skeletons.dart';

import '../../common/const/color.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/utils/pagination_utils.dart';
import '../../product/component/product_card.dart';
import '../../product/model/product_model.dart';
import '../../rating/rating_model.dart';
import '../../user/provider/basket_provider.dart';
import '../model/restaurant_model.dart';

import 'basket_screen.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'restaruantDetail';

  final String id;

  const RestaurantDetailScreen({required this.id, Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(
        restaurantRatingProvider(widget.id).notifier,
      ),
    );
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
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if (state == null) {
      return const DefalutLayout(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }

    return DefalutLayout(
        title: '불타는 떡볶이',
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pushNamed(BasketScreen.routeName);
          },
          backgroundColor: PRIMARY_COLOR,
          child: Badge(
            showBadge: basket.isNotEmpty, //장바구니가 비어있을 때
            badgeContent: Text(
              //장바구니 안에 숫자
              basket
                  .fold<int>(
                    0,
                    (previous, next) => previous + next.count,
                  )
                  .toString(),
              style: const TextStyle(
                color: PRIMARY_COLOR,
                fontSize: 10.0,
              ),
            ),
            badgeColor: Colors.white,
            child: const Icon(
              Icons.shopping_basket_outlined,
            ),
          ),
        ),
        child: CustomScrollView(
          slivers: [
            renderTop(model: state),
            if (state is! RestaurantDetailModel) renderLoading(),
            if (state is RestaurantDetailModel) renderLabel(),
            if (state is RestaurantDetailModel)
              renderProducts(products: state.products, restaurant: state),
            if (ratingsState is CursorPagination<RatingModel>)
              renderRatings(
                models: ratingsState.data,
              )
          ],
        ));
  }

  SliverPadding renderRatings({
    required List<RatingModel> models,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RatingCard.fromModel(
              model: models[index],
            ),
          ),
          childCount: models.length,
        ),
      ),
    );
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

  SliverPadding renderProducts({
    required RestaurantModel restaurant,
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];

            return InkWell(
              onTap: () {
                ref.read(basketProvider.notifier).addToBasket(
                      product: ProductModel(
                        id: model.id,
                        name: model.name,
                        detail: model.detail,
                        imgUrl: model.imgUrl,
                        price: model.price,
                        restaurant: restaurant,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ProductCard.fromRestaurantProductModel(
                  model: model,
                ),
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
