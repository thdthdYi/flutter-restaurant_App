import 'package:flutter_new_project/common/model/cursor_pagination_model.dart';
import 'package:flutter_new_project/common/model/pagination_params.dart';
import 'package:flutter_new_project/restaurant/model/restaurant_model.dart';
import 'package:flutter_new_project/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//pagination 로직

//입력한 id에 해당되는 데이터만 가져옴
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    //data가 리스트에 없는 상태
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);

  final notifier = RestaurantStateNotifier(repository: repository);

  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  //api 요청
  final RestaurantRepository repository;
  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    //class가 생성될 때 바로 호출. ui에서 data호출에 대해 생각할 필요가 없음
    paginate();
  }

//statenorifier
  Future<void> paginate({
    int fetchCount = 20, //params count와 동일
    //false = 새로고침
    bool fetchMore = false, //추가 데이터 가져오기 -true
    //강제로 로딩
    //true = CursorPAginationLoading()
    bool forceRefetch = false,
  }) async {
    try {
      //이미 CursorPagination에서 RetaurantModel로 받고 있음.
      // final resp = await repository.paginate();

      // state = resp;

      ///state의 상태
      ///1) CursorPagination - 정상적 데이터가 있는 상태
      ///2) CursorPaginationLoading - 로딩(캐시없음)
      ///3) CursorPaginationError
      ///4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터 가져옴
      ///5) CursorPaginationFetchMore - 추가 데이터 Paginate 요청
      ///
      ///바로 반환
      ///1) hasMore = false (이미 다음 데이터가 없음)
      ///2) 로딩 - fetchMore : true (이미 요청 중)
      /// fetchMore가 아닐 때 - 기존 요청이 중요하지 않음 , 재 새로고침

      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        if (!pState.meta.hasMore) {
          return; //더이상의 데이터가 없으므로
        }
      }

      final isLoaing = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      if (fetchMore && (isLoaing || isRefetching || isFetchingMore)) {
        return;
      }

//paginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      //fetchMore 데이터 추가
      if (fetchMore) {
        final pState = state as CursorPagination;

        state =
            CursorPaginationFetchingMore(meta: pState.meta, data: pState.data);

        paginationParams =
            paginationParams.copyWith(after: pState.data.last.id);
      }
      //데이터를 처음부터 가지고 오는 경우
      else {
        //데이터가 있는 상황, 기존 데이터를 보존한 채로 api요청
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;

          state =
              CursorPaginationRefetching(meta: pState.meta, data: pState.data);
        } else {
          //데이터 유지할 필요없음
          state = CursorPaginationLoading();
        }
      }

      final resp =
          await repository.paginate(paginationParams: paginationParams);

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        //data가 모두 받아졌으므로 loading에서 데이터로 변화
        state = resp.copyWith(
            //기존데이터 + 새로운데이터
            data: [...pState.data, ...resp.data]);
      } else {
        //loading or Refetching

        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: "데이터를 가져오지 못했습니다.");
    }
  }

  void getDetail({
    required String id,
  }) async {
    //만약 데이터가 하나도 없는 상태 : CursorPagination != 데이터를 가져오는 시도를 한다
    if (state is! CursorPagination) {
      await this.paginate();
    }

    //state가 CursorPagination이 아닐 때, 그냥 리턴
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>((e) => e.id == id ? resp : e)
            .toList());
  }
}
