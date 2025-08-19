// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'dart:async';
//
// import '../viewmodels/chat_repository.dart';
//
// abstract class ChatEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
// class ChatStart extends ChatEvent {}
// class ChatSelectPeer extends ChatEvent {
//   final String peerId;
//   ChatSelectPeer(this.peerId);
// }
// class ChatSendMessage extends ChatEvent {
//   final String text;
//   ChatSendMessage(this.text);
// }
// class ChatMessageReceived extends ChatEvent {
//   final Map<String, dynamic> message;
//   ChatMessageReceived(this.message);
// }
// class ChatMessagesLoaded extends ChatEvent {
//   final List<dynamic> messages;
//   ChatMessagesLoaded(this.messages);
// }
// class ChatConnectionStatusChanged extends ChatEvent {
//   final String status;
//   ChatConnectionStatusChanged(this.status);
// }
//
// abstract class ChatState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
// class ChatInitial extends ChatState {}
// class ChatLoading extends ChatState {}
// class ChatReady extends ChatState {
//   final List<dynamic> users;
//   final String? selectedPeerId;
//   final List<dynamic> messages;
//   final String connectionStatus;
//   ChatReady({required this.users, this.selectedPeerId, required this.messages, required this.connectionStatus});
//
//   ChatReady copyWith({List<dynamic>? users, String? selectedPeerId, List<dynamic>? messages, String? connectionStatus}) {
//     return ChatReady(
//       users: users ?? this.users,
//       selectedPeerId: selectedPeerId ?? this.selectedPeerId,
//       messages: messages ?? this.messages,
//       connectionStatus: connectionStatus ?? this.connectionStatus,
//     );
//   }
//
//   @override
//   List<Object?> get props => [users, selectedPeerId, messages, connectionStatus];
// }
//
// class ChatError extends ChatState {
//   final String message;
//   ChatError(this.message);
//   @override
//   List<Object?> get props => [message];
// }
//
// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final ChatRepository repo;
//   StreamSubscription? _messageSubscription;
//   StreamSubscription? _statusSubscription;
//   StreamSubscription? _messagesSubscription;
//
//   ChatBloc(this.repo) : super(ChatInitial()) {
//     on<ChatStart>((event, emit) async {
//       try {
//         emit(ChatLoading());
//
//         // Connect socket
//         await repo.connectSocket();
//
//         // Set up socket listeners with proper event handling
//         _setupSocketListeners();
//
//         // Fetch users
//         final users = await repo.fetchUsers();
//         print('Fetched ${users.length} users');
//
//         emit(ChatReady(
//             users: users,
//             messages: [],
//             connectionStatus: repo.socket.connected ? 'Connected' : 'Connecting'
//         ));
//       } catch (e) {
//         print('Error in ChatStart: $e');
//         emit(ChatError('Failed to load users: ${e.toString()}'));
//       }
//     });
//
//     on<ChatSelectPeer>((event, emit) async {
//       if (state is! ChatReady) return;
//       try {
//         // Clear existing messages and set selected peer
//         emit((state as ChatReady).copyWith(selectedPeerId: event.peerId, messages: []));
//
//         // Fetch message history
//         repo.socket.emit('fetch-messages', {'withUserId': event.peerId, 'limit': 50});
//       } catch (e) {
//         print('Error selecting peer: $e');
//       }
//     });
//
//     on<ChatSendMessage>((event, emit) async {
//       if (state is! ChatReady) return;
//       try {
//         final s = state as ChatReady;
//         if (s.selectedPeerId == null) return;
//
//         // Send message via socket
//         repo.socket.emit('chat-message', {'to': s.selectedPeerId, 'text': event.text});
//
//         print('Message sent: ${event.text}');
//       } catch (e) {
//         print('Error sending message: $e');
//       }
//     });
//
//     on<ChatMessageReceived>((event, emit) {
//       if (state is ChatReady) {
//         final currentState = state as ChatReady;
//         final newMessages = List<dynamic>.from(currentState.messages);
//         newMessages.add(event.message);
//         emit(currentState.copyWith(messages: newMessages));
//       }
//     });
//
//     on<ChatMessagesLoaded>((event, emit) {
//       if (state is ChatReady) {
//         final currentState = state as ChatReady;
//         emit(currentState.copyWith(messages: event.messages));
//       }
//     });
//
//     on<ChatConnectionStatusChanged>((event, emit) {
//       if (state is ChatReady) {
//         final currentState = state as ChatReady;
//         emit(currentState.copyWith(connectionStatus: event.status));
//       }
//     });
//   }
//
//   void _setupSocketListeners() {
//     // Connection status listener - Use scheduleMicrotask to defer the add call
//     repo.socket.on('connection-status', (data) {
//       if (!isClosed) {
//         scheduleMicrotask(() {
//           if (!isClosed) {
//             add(ChatConnectionStatusChanged(data['status'] ?? 'Unknown'));
//           }
//         });
//       }
//     });
//
//     // New message listener - Use scheduleMicrotask to defer the add call
//     repo.socket.on('chat-message', (data) {
//       print('Received message: $data');
//       if (!isClosed) {
//         scheduleMicrotask(() {
//           if (!isClosed) {
//             add(ChatMessageReceived(data));
//           }
//         });
//       }
//     });
//
//     // Message history listener - Use scheduleMicrotask to defer the add call
//     repo.socket.on('messages', (payload) {
//       print('Received message history: ${payload.length} messages');
//       if (!isClosed) {
//         scheduleMicrotask(() {
//           if (!isClosed) {
//             add(ChatMessagesLoaded(List<dynamic>.from(payload)));
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   Future<void> close() {
//     _messageSubscription?.cancel();
//     _statusSubscription?.cancel();
//     _messagesSubscription?.cancel();
//     repo.socket.disconnect();
//     return super.close();
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../viewmodels/chat_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../viewmodels/chat_repository.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class ChatStart extends ChatEvent {}
class ChatSelectPeer extends ChatEvent {
  final String peerId;
  ChatSelectPeer(this.peerId);
}
class ChatSendMessage extends ChatEvent {
  final String text;
  ChatSendMessage(this.text);
}
class ChatMessageReceived extends ChatEvent {
  final Map<String, dynamic> message;
  ChatMessageReceived(this.message);
}
class ChatMessagesLoaded extends ChatEvent {
  final List<dynamic> messages;
  ChatMessagesLoaded(this.messages);
}
class ChatConnectionStatusChanged extends ChatEvent {
  final String status;
  ChatConnectionStatusChanged(this.status);
}

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatReady extends ChatState {
  final List<dynamic> users;
  final String? selectedPeerId;
  final List<dynamic> messages;
  final String connectionStatus;
  final String? currentUserId;

  ChatReady({
    required this.users,
    this.selectedPeerId,
    required this.messages,
    required this.connectionStatus,
    this.currentUserId,
  });

  ChatReady copyWith({
    List<dynamic>? users,
    String? selectedPeerId,
    List<dynamic>? messages,
    String? connectionStatus,
    String? currentUserId,
  }) {
    return ChatReady(
      users: users ?? this.users,
      selectedPeerId: selectedPeerId ?? this.selectedPeerId,
      messages: messages ?? this.messages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props => [users, selectedPeerId, messages, connectionStatus, currentUserId];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repo;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc(this.repo) : super(ChatInitial()) {
    on<ChatStart>((event, emit) async {
      try {
        emit(ChatLoading());

        // Get current user ID from stored token
        final currentUserId = await _getCurrentUserId();
        print('Current User ID: $currentUserId');

        // Connect socket
        await repo.connectSocket();

        // Set up socket listeners with proper event handling
        _setupSocketListeners();

        // Fetch users
        final users = await repo.fetchUsers();
        print('Fetched ${users.length} users');

        // Load persisted messages
        final persistedMessages = await _loadMessagesFromStorage();

        emit(ChatReady(
          users: users,
          messages: persistedMessages,
          connectionStatus: repo.socket.connected ? 'Connected' : 'Connecting',
          currentUserId: currentUserId,
        ));
      } catch (e) {
        print('Error in ChatStart: $e');
        emit(ChatError('Failed to load users: ${e.toString()}'));
      }
    });

    on<ChatSelectPeer>((event, emit) async {
      if (state is! ChatReady) return;
      try {
        final currentState = state as ChatReady;

        // Load messages for this specific peer from storage
        final peerMessages = await _loadPeerMessagesFromStorage(event.peerId, currentState.currentUserId ?? '');

        // Set selected peer and load their messages
        emit(currentState.copyWith(selectedPeerId: event.peerId, messages: peerMessages));

        // Also fetch fresh messages from server
        repo.socket.emit('fetch-messages', {'withUserId': event.peerId, 'limit': 50});

        print('Selected peer: ${event.peerId}, loaded ${peerMessages.length} cached messages');
      } catch (e) {
        print('Error selecting peer: $e');
      }
    });

    on<ChatSendMessage>((event, emit) async {
      if (state is! ChatReady) return;
      try {
        final s = state as ChatReady;
        if (s.selectedPeerId == null || s.currentUserId == null) return;

        // Generate a unique local ID for this message
        final localId = 'local_${DateTime.now().millisecondsSinceEpoch}_${event.text.hashCode}';

        // Create local message object
        final localMessage = {
          'id': localId,
          'from': s.currentUserId,
          'to': s.selectedPeerId,
          'text': event.text,
          'createdAt': DateTime.now().toIso8601String(),
          'isLocal': true, // Mark as local until confirmed by server
          'localId': localId, // Store the local ID for tracking
        };

        // Add message to current state immediately for instant UI feedback
        final updatedMessages = List<dynamic>.from(s.messages)..add(localMessage);
        emit(s.copyWith(messages: updatedMessages));

        // Save to local storage
        await _saveMessageToStorage(localMessage);

        // Send message via socket with local ID for tracking
        repo.socket.emit('chat-message', {
          'to': s.selectedPeerId,
          'text': event.text,
          'localId': localId
        });

        print('Message sent: ${event.text} with localId: $localId');
      } catch (e) {
        print('Error sending message: $e');
      }
    });

    on<ChatMessageReceived>((event, emit) async {
      if (state is ChatReady) {
        final currentState = state as ChatReady;

        // Check if this is a response to a local message we sent
        final localId = event.message['localId']?.toString();
        final messageText = event.message['text']?.toString() ?? '';
        final messageFrom = event.message['from']?.toString() ?? '';
        final messageTo = event.message['to']?.toString() ?? '';

        // Find and replace local message if this is a confirmation
        int localMessageIndex = -1;
        if (localId != null) {
          // Look for message with matching localId
          localMessageIndex = currentState.messages.indexWhere((m) =>
          m['localId'] == localId ||
              (m['isLocal'] == true &&
                  m['text'] == messageText &&
                  m['from'] == messageFrom &&
                  m['to'] == messageTo)
          );
        } else {
          // Fallback: look for similar local message sent recently (within last 5 seconds)
          final now = DateTime.now();
          localMessageIndex = currentState.messages.indexWhere((m) {
            if (m['isLocal'] != true) return false;

            final msgTime = DateTime.tryParse(m['createdAt']?.toString() ?? '');
            final timeDiff = msgTime != null ? now.difference(msgTime).inSeconds : 999;

            return timeDiff <= 5 &&
                m['text'] == messageText &&
                m['from'] == messageFrom &&
                m['to'] == messageTo;
          });
        }

        final updatedMessages = List<dynamic>.from(currentState.messages);

        if (localMessageIndex != -1) {
          // Replace local message with server message
          final serverMessage = Map<String, dynamic>.from(event.message);
          serverMessage.remove('isLocal');
          serverMessage.remove('localId');
          updatedMessages[localMessageIndex] = serverMessage;
          print('Replaced local message with server confirmation: $messageText');
        } else {
          // Check if this exact message already exists (to prevent true duplicates)
          final existingIndex = currentState.messages.indexWhere((m) =>
          m['id'] == event.message['id'] && m['isLocal'] != true
          );

          if (existingIndex == -1) {
            // New message from another user, add it
            final serverMessage = Map<String, dynamic>.from(event.message);
            serverMessage.remove('isLocal');
            serverMessage.remove('localId');
            updatedMessages.add(serverMessage);
            print('Added new message from other user: $messageText');
          } else {
            print('Ignored duplicate message: $messageText');
            return; // Don't emit if it's a duplicate
          }
        }

        emit(currentState.copyWith(messages: updatedMessages));

        // Save to local storage
        final messageToSave = Map<String, dynamic>.from(event.message);
        messageToSave.remove('isLocal');
        messageToSave.remove('localId');
        await _saveMessageToStorage(messageToSave);
      }
    });

    on<ChatMessagesLoaded>((event, emit) async {
      if (state is ChatReady) {
        final currentState = state as ChatReady;

        // Merge server messages with local messages, avoiding duplicates
        final mergedMessages = _mergeMessages(currentState.messages, event.messages);
        emit(currentState.copyWith(messages: mergedMessages));

        // Save all messages to storage
        for (final message in event.messages) {
          await _saveMessageToStorage(message);
        }

        print('Loaded ${event.messages.length} messages from server, total: ${mergedMessages.length}');
      }
    });

    on<ChatConnectionStatusChanged>((event, emit) {
      if (state is ChatReady) {
        final currentState = state as ChatReady;
        emit(currentState.copyWith(connectionStatus: event.status));
      }
    });
  }

  void _setupSocketListeners() {
    // Connection status listener
    repo.socket.on('connection-status', (data) {
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatConnectionStatusChanged(data['status'] ?? 'Unknown'));
          }
        });
      }
    });

    // New message listener
    repo.socket.on('chat-message', (data) {
      print('Received message: $data');
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatMessageReceived(data));
          }
        });
      }
    });

    // Message history listener
    repo.socket.on('messages', (payload) {
      print('Received message history: ${payload.length} messages');
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatMessagesLoaded(List<dynamic>.from(payload)));
          }
        });
      }
    });

    // Socket connection events
    repo.socket.on('connect', (_) {
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatConnectionStatusChanged('Connected'));
          }
        });
      }
    });

    repo.socket.on('disconnect', (_) {
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatConnectionStatusChanged('Disconnected'));
          }
        });
      }
    });
  }

  // Get current user ID from JWT token
  Future<String?> _getCurrentUserId() async {
    try {
      final token = await repo.secureStore.getToken();
      if (token != null) {
        // Decode JWT token to get user ID
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = parts[1];
          // Add padding if needed
          final normalizedPayload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
          final decodedBytes = base64Url.decode(normalizedPayload);
          final decodedPayload = utf8.decode(decodedBytes);
          final payloadMap = json.decode(decodedPayload);
          return payloadMap['userId'] ?? payloadMap['id'] ?? payloadMap['sub'];
        }
      }
    } catch (e) {
      print('Error decoding token: $e');
    }
    return null;
  }

  // Load all messages from SharedPreferences
  Future<List<dynamic>> _loadMessagesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages') ?? [];
      return messagesJson.map((json) => jsonDecode(json)).toList();
    } catch (e) {
      print('Error loading messages from storage: $e');
      return [];
    }
  }

  // Load messages for a specific peer conversation
  Future<List<dynamic>> _loadPeerMessagesFromStorage(String peerId, String currentUserId) async {
    try {
      final allMessages = await _loadMessagesFromStorage();
      return allMessages.where((m) {
        final fromId = m['from']?.toString() ?? '';
        final toId = m['to']?.toString() ?? '';
        return (fromId == peerId && toId == currentUserId) ||
            (fromId == currentUserId && toId == peerId);
      }).toList();
    } catch (e) {
      print('Error loading peer messages: $e');
      return [];
    }
  }

  // Save a message to SharedPreferences
  Future<void> _saveMessageToStorage(Map<String, dynamic> message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages') ?? [];

      // Check if message already exists
      final messageId = message['id']?.toString();
      final existingIndex = messagesJson.indexWhere((json) {
        final existing = jsonDecode(json);
        return existing['id'] == messageId ||
            (existing['from'] == message['from'] &&
                existing['to'] == message['to'] &&
                existing['text'] == message['text'] &&
                existing['createdAt'] == message['createdAt']);
      });

      if (existingIndex != -1) {
        // Update existing message
        messagesJson[existingIndex] = jsonEncode(message);
      } else {
        // Add new message
        messagesJson.add(jsonEncode(message));
      }

      // Keep only last 1000 messages to prevent storage bloat
      if (messagesJson.length > 1000) {
        messagesJson.removeRange(0, messagesJson.length - 1000);
      }

      await prefs.setStringList('chat_messages', messagesJson);
    } catch (e) {
      print('Error saving message to storage: $e');
    }
  }

  // Merge server messages with local messages, avoiding duplicates
  List<dynamic> _mergeMessages(List<dynamic> localMessages, List<dynamic> serverMessages) {
    final merged = <dynamic>[];
    final processedIds = <String>{};
    final processedMessages = <String>{};

    // First, add all server messages (they are authoritative)
    for (final serverMsg in serverMessages) {
      final id = serverMsg['id']?.toString() ?? '';
      final messageKey = '${serverMsg['from']}_${serverMsg['to']}_${serverMsg['text']}_${serverMsg['createdAt']}';

      if (id.isNotEmpty && !processedIds.contains(id) && !processedMessages.contains(messageKey)) {
        final cleanMsg = Map<String, dynamic>.from(serverMsg);
        cleanMsg.remove('isLocal');
        cleanMsg.remove('localId');
        merged.add(cleanMsg);
        processedIds.add(id);
        processedMessages.add(messageKey);
      }
    }

    // Then add local messages that don't have server counterparts yet
    for (final localMsg in localMessages) {
      final id = localMsg['id']?.toString() ?? '';
      final isLocal = localMsg['isLocal'] == true;
      final messageKey = '${localMsg['from']}_${localMsg['to']}_${localMsg['text']}';

      if (isLocal) {
        // Check if a similar server message already exists
        final hasServerCounterpart = serverMessages.any((serverMsg) =>
        serverMsg['from'] == localMsg['from'] &&
            serverMsg['to'] == localMsg['to'] &&
            serverMsg['text'] == localMsg['text']
        );

        if (!hasServerCounterpart && id.isNotEmpty && !processedIds.contains(id)) {
          merged.add(localMsg);
          processedIds.add(id);
        }
      }
    }

    // Sort by timestamp
    merged.sort((a, b) {
      final aTime = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    return merged;
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _messagesSubscription?.cancel();
    repo.socket.disconnect();
    return super.close();
  }
}