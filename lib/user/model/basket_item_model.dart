import 'package:json_annotation/json_annotation.dart';

import '../../product/model/product_model.dart';

part 'basket_item_model.g.dart';

@JsonSerializable()
class BasketItemModel {
  final ProductModel product;
  final int count;

  BasketItemModel({
    required this.product,
    required this.count,
  });

//상품의 가격이 변동될 수 있도록
  BasketItemModel copyWith({
    ProductModel? product,
    int? count,
  }) {
    return BasketItemModel(
      product: product ?? this.product,
      count: count ?? this.count,
    );
  }

  factory BasketItemModel.fromJson(Map<String, dynamic> json) =>
      _$BasketItemModelFromJson(json);
}
