import 'package:chat_client/viewmodels/auth_repository.dart';
import 'package:chat_client/views/chat_list_view.dart';
import 'package:chat_client/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
      ],
      child: BlocProvider(
        create: (ctx) => AuthBloc(ctx.read<AuthRepository>())..add(AuthStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const ChatListView();
              }
              if (state is AuthLoading) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return const LoginView();
            },
          ),
        ),
      ),
    );
  }
}
