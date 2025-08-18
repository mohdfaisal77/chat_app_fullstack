import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 28, child: Icon(Icons.chat, size: 30)),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('Welcome back', style: TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Sign in to continue', style: TextStyle(color: Colors.white70)),
                        ])
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _email,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                            obscureText: true,
                          ),
                          const SizedBox(height: 18),
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is Authenticated) {
                                // handled by parent navigator
                              } else if (state is AuthFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                              }
                            },
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading
                                      ? null
                                      : () {
                                    context.read<AuthBloc>().add(AuthLoginRequested(_email.text.trim(), _password.text));
                                  },
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: state is AuthLoading
                                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Sign in'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/signup'); // adapt to your route
                            },
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
