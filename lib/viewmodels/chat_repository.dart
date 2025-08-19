// import 'dart:io';
// import 'package:chat_client/viewmodels/secure_storage.dart';
// import 'package:device_info_plus/device_info_plus.dart';
//
// import '../services/api_service.dart';
// import '../services/socket_service.dart';
//
// class ChatRepository {
//   final SecureStore _store = SecureStore();
//   ApiService? _api;
//   final SocketService socket = SocketService();
//   String? _baseUrl;
//
//   // Initialize the API service
//   Future<void> _ensureApiInitialized() async {
//     if (_api != null && _baseUrl != null) return;
//
//     _baseUrl = "http://10.0.2.2:4000"; // default for emulator
//
//     if (Platform.isAndroid) {
//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;
//       if (androidInfo.isPhysicalDevice) {
//         _baseUrl = "http://192.168.31.94:4000";
//       }
//     } else if (Platform.isIOS) {
//       final deviceInfo = DeviceInfoPlugin();
//       final iosInfo = await deviceInfo.iosInfo;
//       if (iosInfo.isPhysicalDevice) {
//         _baseUrl = "http://192.168.31.94:4000";
//       } else {
//         _baseUrl = "http://localhost:4000";
//       }
//     }
//
//     _api = ApiService(_baseUrl!);
//     print('ChatRepository initialized with baseUrl: $_baseUrl');
//   }
//
//   Future<List<dynamic>> fetchUsers() async {
//     await _ensureApiInitialized();
//     final token = await _store.getToken();
//     if (token == null) {
//       throw Exception('No authentication token found');
//     }
//
//     print('Fetching users with token: ${token.substring(0, 10)}...');
//     print('API URL: $_baseUrl/api/users');
//
//     try {
//       final users = await _api!.get('/api/users', token: token);
//       print('Successfully fetched ${users.length} users');
//       return users;
//     } catch (e) {
//       print('Error fetching users: $e');
//       rethrow;
//     }
//   }
//
//   Future<List<dynamic>> fetchMessages(String peerId) async {
//     await _ensureApiInitialized();
//     final token = await _store.getToken();
//     if (token == null) {
//       throw Exception('No authentication token found');
//     }
//
//     try {
//       final messages = await _api!.get('/api/messages/$peerId', token: token);
//       return messages;
//     } catch (e) {
//       print('Error fetching messages: $e');
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> sendMessage(String peerId, String text) async {
//     await _ensureApiInitialized();
//     final token = await _store.getToken();
//     if (token == null) {
//       throw Exception('No authentication token found');
//     }
//
//     try {
//       final result = await _api!.post('/api/messages/send', {
//         "to": peerId,
//         "text": text,
//       }, token: token);
//       return result;
//     } catch (e) {
//       print('Error sending message: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> connectSocket() async {
//     final token = await _store.getToken();
//     if (token == null) {
//       print('No token available for socket connection');
//       return;
//     }
//
//     await _ensureApiInitialized();
//     print('Connecting socket to: $_baseUrl');
//     socket.connect(_baseUrl!, token);
//   }
// }

import 'dart:io';
import 'package:chat_client/viewmodels/secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatRepository {
  final SecureStore _store = SecureStore();
  ApiService? _api;
  final SocketService socket = SocketService();
  String? _baseUrl;

  // Public getter for SecureStore so ChatBloc can access it
  SecureStore get secureStore => _store;

  // Initialize the API service
  Future<void> _ensureApiInitialized() async {
    if (_api != null && _baseUrl != null) return;

    _baseUrl = "http://10.0.2.2:4000"; // default for emulator

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.isPhysicalDevice) {
        _baseUrl = "http://192.168.31.94:4000";
      }
    } else if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice) {
        _baseUrl = "http://192.168.31.94:4000";
      } else {
        _baseUrl = "http://localhost:4000";
      }
    }

    _api = ApiService(_baseUrl!);
    print('ChatRepository initialized with baseUrl: $_baseUrl');
  }

  Future<List<dynamic>> fetchUsers() async {
    await _ensureApiInitialized();
    final token = await _store.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    print('Fetching users with token: ${token.substring(0, 10)}...');
    print('API URL: $_baseUrl/api/users');

    try {
      final users = await _api!.get('/api/users', token: token);
      print('Successfully fetched ${users.length} users');
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMessages(String peerId) async {
    await _ensureApiInitialized();
    final token = await _store.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final messages = await _api!.get('/api/messages/$peerId', token: token);
      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(String peerId, String text) async {
    await _ensureApiInitialized();
    final token = await _store.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final result = await _api!.post('/api/messages/send', {
        "to": peerId,
        "text": text,
      }, token: token);
      return result;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> connectSocket() async {
    final token = await _store.getToken();
    if (token == null) {
      print('No token available for socket connection');
      return;
    }

    await _ensureApiInitialized();
    print('Connecting socket to: $_baseUrl');
    socket.connect(_baseUrl!, token);
  }
}