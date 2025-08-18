import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

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
  ChatReady({required this.users, this.selectedPeerId, required this.messages, required this.connectionStatus});

  ChatReady copyWith({List<dynamic>? users, String? selectedPeerId, List<dynamic>? messages, String? connectionStatus}) {
    return ChatReady(
      users: users ?? this.users,
      selectedPeerId: selectedPeerId ?? this.selectedPeerId,
      messages: messages ?? this.messages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  List<Object?> get props => [users, selectedPeerId, messages, connectionStatus];
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

        // Connect socket
        await repo.connectSocket();

        // Set up socket listeners with proper event handling
        _setupSocketListeners();

        // Fetch users
        final users = await repo.fetchUsers();
        print('Fetched ${users.length} users');

        emit(ChatReady(
            users: users,
            messages: [],
            connectionStatus: repo.socket.connected ? 'Connected' : 'Connecting'
        ));
      } catch (e) {
        print('Error in ChatStart: $e');
        emit(ChatError('Failed to load users: ${e.toString()}'));
      }
    });

    on<ChatSelectPeer>((event, emit) async {
      if (state is! ChatReady) return;
      try {
        // Clear existing messages and set selected peer
        emit((state as ChatReady).copyWith(selectedPeerId: event.peerId, messages: []));

        // Fetch message history
        repo.socket.emit('fetch-messages', {'withUserId': event.peerId, 'limit': 50});
      } catch (e) {
        print('Error selecting peer: $e');
      }
    });

    on<ChatSendMessage>((event, emit) async {
      if (state is! ChatReady) return;
      try {
        final s = state as ChatReady;
        if (s.selectedPeerId == null) return;

        // Send message via socket
        repo.socket.emit('chat-message', {'to': s.selectedPeerId, 'text': event.text});

        print('Message sent: ${event.text}');
      } catch (e) {
        print('Error sending message: $e');
      }
    });

    on<ChatMessageReceived>((event, emit) {
      if (state is ChatReady) {
        final currentState = state as ChatReady;
        final newMessages = List<dynamic>.from(currentState.messages);
        newMessages.add(event.message);
        emit(currentState.copyWith(messages: newMessages));
      }
    });

    on<ChatMessagesLoaded>((event, emit) {
      if (state is ChatReady) {
        final currentState = state as ChatReady;
        emit(currentState.copyWith(messages: event.messages));
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
    // Connection status listener - Use scheduleMicrotask to defer the add call
    repo.socket.on('connection-status', (data) {
      if (!isClosed) {
        scheduleMicrotask(() {
          if (!isClosed) {
            add(ChatConnectionStatusChanged(data['status'] ?? 'Unknown'));
          }
        });
      }
    });

    // New message listener - Use scheduleMicrotask to defer the add call
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

    // Message history listener - Use scheduleMicrotask to defer the add call
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