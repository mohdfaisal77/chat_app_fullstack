import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../viewmodels/chat_repository.dart';
import 'chat_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ChatRepository(),
      child: BlocProvider(
        create: (ctx) => ChatBloc(ctx.read<ChatRepository>())..add(ChatStart()),
        child: Scaffold(
          appBar: AppBar(
            elevation: 2,
            title: Row(
              children: [
                const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Welcome', style: TextStyle(fontSize: 12)),
                    Text('Chat App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                icon: const Icon(Icons.logout_rounded),
              )
            ],
          ),
          body: SafeArea(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                print('ChatListView state: ${state.runtimeType}'); // Debug

                if (state is ChatLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading users...'),
                      ],
                    ),
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ChatBloc>().add(ChatStart()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChatReady) {
                  print('ChatReady with ${state.users.length} users'); // Debug

                  if (state.users.isEmpty) {
                    return _emptyState(context);
                  }

                  return Column(
                    children: [
                      // Connection status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: state.connectionStatus.toLowerCase().contains('connect')
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: state.connectionStatus.toLowerCase().contains('connect')
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.connectionStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: state.connectionStatus.toLowerCase().contains('connect')
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // User list
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (ctx, i) {
                            final u = state.users[i];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text((u['email'] ?? '?')[0].toUpperCase()),
                              ),
                              title: Text(u['email'] ?? 'Unknown'),
                              subtitle: Text('Tap to start chat'),
                              onTap: () {
                                // Select peer first
                                context.read<ChatBloc>().add(ChatSelectPeer(u['_id'] ?? ''));

                                // Navigate with the existing BLoC
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ChatBloc>(),
                                      child: ChatView(
                                        peerId: u['_id'] ?? '',
                                        peerEmail: u['email'] ?? '',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const Center(child: Text("Initializing..."));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline, size: 72, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        const SizedBox(height: 12),
        const Text('No other users found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Create another account to start chatting.',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<ChatBloc>().add(ChatStart()),
          child: const Text('Refresh'),
        ),
      ],
    ),
  );
}