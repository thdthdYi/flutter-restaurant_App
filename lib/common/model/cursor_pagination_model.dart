import 'package:flutter_new_project/restaurant/model/restaurant_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

abstract class CursorPaginationBase {}

//error가 있을 때
class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({required this.message});
}

//loaing 상태
class CursorPaginationLoading extends CursorPaginationBase {}

@JsonSerializable(
  genericArgumentFactories: true, //generic을 고려한 code generation.
)

//데이터 성공
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    List<T>? data,
  }) {
    return CursorPagination<T>(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

//T type이 json으로부터 어떻게 들어오는지 정의가 필요.
  factory CursorPagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({required this.count, required this.hasMore});

  CursorPaginationMeta copyWith({int? count, bool? hasMore}) {
    return CursorPaginationMeta(
        count: count ?? this.count, hasMore: hasMore ?? this.hasMore);
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

//새로고침 Data가 있는 상태에서 사용할 수 밖에 없음
class CursorPaginationRefetching<T> extends CursorPagination {
  CursorPaginationRefetching({required super.meta, required super.data});
}

//리스트의 맨 아래로 내려서 추가 데이터를 요청하는 중
class CursorPaginationFetchingMore<T> extends CursorPagination {
  CursorPaginationFetchingMore({required super.meta, required super.data});
}
