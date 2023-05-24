import 'package:flutter/material.dart';
import 'package:flutter_new_project/common/component/pagination_list_view.dart';

import 'package:flutter_new_project/restaurant/component/retaurant_card.dart';

import 'package:flutter_new_project/restaurant/provider/restaurant_provider.dart';

import 'package:flutter_new_project/restaurant/view/restaurant_detail_screen.dart';
import 'package:go_router/go_router.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context.goNamed(
              RestaurantDetailScreen.routeName,
              params: {
                'rid': model.id,
              },
            );
          },
          child: RestaurantCard.fromModel(
            model: model,
          ),
        );
      },
    );
  }
}
  //현재위치가 최대 길이에 가까운 위치에 오면 추가 데이터 요청

  //   if (controller.offset > controller.position.maxScrollExtent - 300) {
  //     ref.read(restaurantProvider.notifier).paginate(
  //           fetchMore: true,
  //         );
  //   }
  // }
////dioProvider 상태관리로 변경
  ///
//     final dio = ref.watch(dioProvider);
//     // final dio = Dio();

//     // dio.interceptors.add(CustomInterceptor(storage: storage));

//     final resp =
//         await RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant')
//             .paginate();

// /*
//     //storage에서 accesstoken 가져오기
//     final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

//     //restaurant url에 accesstoken을 넣어 요청 보내기
//     final resp = await dio.get('http://$ip/restaurant',
//         options: Options(headers: {
//           'authorization': 'Bearer $accessToken',
//         }));*/

//     return resp.data;
//   }


// //첫 화면 로딩
//     if (data is CursorPaginationLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

// //error
//     if (data is CursorPaginationError) {
//       return Center(
//         child: Text(data.message),
//       );
//     }

//     //CursorPagination
//     //cursorPaginationFetchMore
//     //CursorPaginationRefetching

//     // if (data.length == 0) {
//     //   return const Center(
//     //     child: CircularProgressIndicator(),
//     //   );
//     // }

//     final cp = data as CursorPagination;

//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ListView.separated(
//             itemCount: cp.data.length + 1,
//             itemBuilder: (_, index) {
//               if (index == cp.data.length) {
//                 return Center(
//                     child: data is CursorPaginationFetchingMore
//                         ? CircularProgressIndicator()
//                         : Text("마지막 데이터 입니다."));
//               }
//               final pItem = cp.data[index];

//               //final pItem = RestaurantModel.fromJson(item);

             

        ///provider 사용시 futurebuilder 필요없음
        ///
        // child: FutureBuilder<CursorPagination<RestaurantModel>>(
        //     future: ref.watch(restaurantRepositoryProvider).paginate(),
        //     builder: (context,
        //         AsyncSnapshot<CursorPagination<RestaurantModel>> snapshot) {
        //       if (!snapshot.hasData) {
        //         return const Center(
        //           child: CircularProgressIndicator(),
        //         );
        //       }

        //     })
      //  );
//   }
// }
