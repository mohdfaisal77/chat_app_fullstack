import 'dart:io';

import 'package:chat_client/viewmodels/secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../services/api_service.dart';
//
//
// class AuthRepository {
//   // Change this to your backend base URL (http://10.0.2.2:4000 for Android emulator)
//   final ApiService _api = ApiService(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.31.94:4000'));
//   final SecureStore _store = SecureStore();
//
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final res = await _api.post('/api/auth/login', {'email': email, 'password': password});
//     await _store.saveToken(res['token']);
//     return res;
//   }
//
//   Future<Map<String, dynamic>> signup(String email, String password) async {
//     final res = await _api.post('/api/auth/signup', {'email': email, 'password': password});
//     return res;
//   }
//
//   Future<String?> token() => _store.getToken();
//   Future<void> logout() => _store.clear();
// }



class AuthRepository {
  late final ApiService _api;
  final SecureStore _store = SecureStore();

  AuthRepository() {
    _initApi();
  }

  Future<void> _initApi() async {
    String baseUrl = "http://10.0.2.2:4000"; // default for emulator

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.isPhysicalDevice) {
        // running on a real Android phone
        baseUrl = "http://192.168.31.94:4000"; //
      }
    } else if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice) {
        baseUrl = "http://192.168.31.94:4000"; //
      } else {
        baseUrl = "http://localhost:4000"; // iOS simulator can access localhost
      }
    }

    _api = ApiService(baseUrl);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    await _store.saveToken(res['token']);
    return res;
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final res = await _api.post('/api/auth/signup', {
      'email': email,
      'password': password,
    });
    return res;
  }

  Future<String?> token() => _store.getToken();
  Future<void> logout() => _store.clear();
}

