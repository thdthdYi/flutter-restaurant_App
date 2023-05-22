import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//하나의 storage 사용 가능
final secureStorageProvider = Provider((ref) => FlutterSecureStorage());
