import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_new_project/common/const/color.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_detail_model.dart';

class ProductCard extends StatelessWidget {
  final Image image;
  final String name;
  final String detail;
  final int price;

  const ProductCard(
      {required this.image,
      required this.name,
      required this.detail,
      required this.price,
      Key? key})
      : super(key: key);

  factory ProductCard.fromModel({
    required RestaurantProductModel model,
  }) {
    //modeling
    return ProductCard(
        image: Image.network(model.imgUrl,
            width: 110, height: 110, fit: BoxFit.cover),
        name: model.name,
        detail: model.detail,
        price: model.price);
  }

  Widget build(BuildContext context) {
    return IntrinsicHeight(
      //Row안에서 Widget들이 각자의 크기로 보여짐
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: image,
          ),
          const SizedBox(
            width: 16.0,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              Text(
                detail,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 14.0, color: BODY_TEXT_COLOR),
              ),
              Text(
                '￦$price',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: PRIMARY_COLOR,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
