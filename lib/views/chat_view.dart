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

class _ChatViewState extends State<ChatView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Select the peer when entering chat
    context.read<ChatBloc>().add(ChatSelectPeer(widget.peerId));
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

  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user['id'] ?? '';
    }
    return '';
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

                  // Filter messages for current conversation
                  final currentUserId = _getCurrentUserId();
                  final messages = state.messages.where((m) {
                    final fromId = m['from']?.toString() ?? '';
                    final toId = m['to']?.toString() ?? '';
                    return (fromId == widget.peerId && toId == currentUserId) ||
                        (fromId == currentUserId && toId == widget.peerId);
                  }).toList();

                  print('Showing ${messages.length} messages for conversation');
                  print('Current user ID: $currentUserId, Peer ID: ${widget.peerId}');

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

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: MessageBubble(
                          isMe: isMe,
                          text: m['text'] ?? '',
                          timestamp: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
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