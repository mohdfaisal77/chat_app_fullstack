// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../bloc/chat_bloc.dart';
// import '../bloc/auth_bloc.dart';
// import 'message_bubble.dart';
//
// class ChatView extends StatefulWidget {
//   final String peerId;
//   final String peerEmail;
//   const ChatView({super.key, required this.peerId, required this.peerEmail});
//
//   @override
//   State<ChatView> createState() => _ChatViewState();
// }
//
// class _ChatViewState extends State<ChatView> {
//   final _controller = TextEditingController();
//   final _scroll = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     // Select the peer when entering chat
//     context.read<ChatBloc>().add(ChatSelectPeer(widget.peerId));
//   }
//
//   void _send() {
//     final txt = _controller.text.trim();
//     if (txt.isEmpty) return;
//
//     context.read<ChatBloc>().add(ChatSendMessage(txt));
//     _controller.clear();
//
//     // Scroll to bottom after sending
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom();
//     });
//   }
//
//   void _scrollToBottom() {
//     if (_scroll.hasClients) {
//       _scroll.animateTo(
//         _scroll.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   String _getCurrentUserId() {
//     final authState = context.read<AuthBloc>().state;
//     if (authState is Authenticated) {
//       return authState.user['id'] ?? '';
//     }
//     return '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//                 radius: 18,
//                 child: Text(widget.peerEmail.isNotEmpty ? widget.peerEmail[0].toUpperCase() : '?')
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: Text(
//                     widget.peerEmail,
//                     style: const TextStyle(fontWeight: FontWeight.w600)
//                 )
//             ),
//           ],
//         ),
//         elevation: 1,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   if (state is! ChatReady) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   // Filter messages for current conversation
//                   final currentUserId = _getCurrentUserId();
//                   final messages = state.messages.where((m) {
//                     final fromId = m['from']?.toString() ?? '';
//                     final toId = m['to']?.toString() ?? '';
//                     return (fromId == widget.peerId && toId == currentUserId) ||
//                         (fromId == currentUserId && toId == widget.peerId);
//                   }).toList();
//
//                   print('Showing ${messages.length} messages for conversation');
//                   print('Current user ID: $currentUserId, Peer ID: ${widget.peerId}');
//
//                   if (messages.isEmpty) {
//                     return Center(
//                       child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey[300]),
//                             const SizedBox(height: 10),
//                             const Text("No messages yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                             const SizedBox(height: 6),
//                             const Text("Send the first message to start the conversation", style: TextStyle(color: Colors.grey)),
//                           ]
//                       ),
//                     );
//                   }
//
//                   // Auto scroll to bottom when messages change
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _scrollToBottom();
//                   });
//
//                   return ListView.builder(
//                     controller: _scroll,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     itemCount: messages.length,
//                     itemBuilder: (context, i) {
//                       final m = messages[i];
//                       final fromId = m['from']?.toString() ?? '';
//                       final isMe = fromId == currentUserId;
//
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         child: MessageBubble(
//                           isMe: isMe,
//                           text: m['text'] ?? '',
//                           timestamp: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             _buildComposer(context),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildComposer(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 8,
//               offset: const Offset(0, -2)
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//               onPressed: () {},
//               icon: const Icon(Icons.add_circle_outline)
//           ),
//           Expanded(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxHeight: 150),
//               child: TextField(
//                 controller: _controller,
//                 minLines: 1,
//                 maxLines: 6,
//                 textInputAction: TextInputAction.newline,
//                 onSubmitted: (_) => _send(),
//                 decoration: InputDecoration(
//                   hintText: 'Type a message',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none
//                   ),
//                   filled: true,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           FloatingActionButton.small(
//             onPressed: _send,
//             child: const Icon(Icons.send),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'message_bubble.dart';


class ChatView extends StatefulWidget {
  final String peerId;
  final String peerEmail;
  const ChatView({super.key, required this.peerId, required this.peerEmail});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _isViewVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Select the peer when entering chat
    context.read<ChatBloc>().add(ChatSelectPeer(widget.peerId));

    // Simulate marking messages as seen when entering chat
    _simulateMessagesSeen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isViewVisible = state == AppLifecycleState.resumed;
    if (_isViewVisible) {
      _simulateMessagesSeen();
    }
  }

  // Simulate marking messages as seen (frontend-only implementation)
  void _simulateMessagesSeen() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isViewVisible) {
        // In a real app, you would send a "message seen" event to the server
        // For now, we'll just trigger a rebuild after a short delay
        setState(() {});
      }
    });
  }

  // Check if a message should be marked as seen (frontend simulation)
  bool _isMessageSeen(Map<String, dynamic> message, String currentUserId) {
    final fromId = message['from']?.toString() ?? '';
    final isMyMessage = fromId == currentUserId;
    final isLocal = message['isLocal'] == true;

    // Only mark sent messages as seen (not local/pending ones)
    // In real implementation, this would be based on server data
    if (isMyMessage && !isLocal) {
      final messageTime = DateTime.tryParse(message['createdAt']?.toString() ?? '');
      if (messageTime != null) {
        // Simulate: messages older than 2 seconds are "seen"
        final now = DateTime.now();
        final timeDiff = now.difference(messageTime).inSeconds;
        return timeDiff > 2;
      }
    }
    return false;
  }

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;

    context.read<ChatBloc>().add(ChatSendMessage(txt));
    _controller.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
                radius: 18,
                child: Text(widget.peerEmail.isNotEmpty ? widget.peerEmail[0].toUpperCase() : '?')
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    widget.peerEmail,
                    style: const TextStyle(fontWeight: FontWeight.w600)
                )
            ),
          ],
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is! ChatReady) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Use the currentUserId from the state instead of trying to extract from AuthBloc
                  final currentUserId = state.currentUserId ?? '';

                  // Filter messages for current conversation
                  final messages = state.messages.where((m) {
                    final fromId = m['from']?.toString() ?? '';
                    final toId = m['to']?.toString() ?? '';

                    return (fromId == widget.peerId && toId == currentUserId) ||
                        (fromId == currentUserId && toId == widget.peerId);
                  }).toList();

                  // Sort messages by timestamp
                  messages.sort((a, b) {
                    final aTime = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
                    final bTime = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
                    return aTime.compareTo(bTime);
                  });

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("No messages yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const Text("Send the first message to start the conversation", style: TextStyle(color: Colors.grey)),
                          ]
                      ),
                    );
                  }

                  // Auto scroll to bottom when messages change
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final fromId = m['from']?.toString() ?? '';
                      final isMe = fromId == currentUserId;
                      final isLocal = m['isLocal'] == true;

                      // Check if message is seen (for sent messages only)
                      final isSeen = _isMessageSeen(m, currentUserId);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: MessageBubble(
                          isMe: isMe,
                          text: m['text'] ?? '',
                          timestamp: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
                          isSeen: isSeen, // Pass the seen status
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -2)
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline)
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _send,
            child: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}