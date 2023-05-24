import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/const/data.dart';
import '../../common/secure_storage/secure_storage.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';
import '../repository/user_me_repository.dart';

//Provider을 이용한 로그인 로직
//login / logout

final userMeProvider =
    StateNotifierProvider<UserMeStateNotifier, UserModelBase?>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userMeRepository = ref.watch(userMeRepositoryProvider);
    final storage = ref.watch(secureStorageProvider);

    return UserMeStateNotifier(
      authRepository: authRepository,
      repository: userMeRepository,
      storage: storage,
    );
  },
);

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    // 내 정보 가져오기
    getMe();
  }

// 내 정보 가져오기
  Future<void> getMe() async {
    //로그인 키 가져옴
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

//Token이 없으면 로그아웃된 상태로 돌아감
    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }

    //final resp = await repository.getMe();

    //state = resp;

    try {
      final resp = await repository.getMe();

      state = resp;
    } catch (e, stack) {
      print(e);
      print(stack);

      state = null;
    }
  }

//로그인
  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try {
      state = UserModelLoading();

//요청
      final resp = await authRepository.login(
        username: username,
        password: password,
      );

      //응답 storage에 넣어주기

      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);

      final userResp = await repository.getMe();

      state = userResp;

      return userResp;
    } catch (e) {
      //에러 상태
      state = UserModelError(message: '로그인에 실패했습니다.');

      return Future.value(state);
    }
  }

//로그아웃
  Future<void> logout() async {
    state = null;

//로그아웃시에는 토큰을 지워줘야함.
    await Future.wait(
      //동시 실행
      [
        storage.delete(key: REFRESH_TOKEN_KEY),
        storage.delete(key: ACCESS_TOKEN_KEY),
      ],
    );
  }
}
