import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';
import 'package:modelo_sqlite/features/auth/presentation/screens/login_screen.dart';
import 'package:modelo_sqlite/menu.dart';

/// Shows a splash while the stored session is being checked, then routes
/// to Login or the main Menu depending on whether it's valid.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAuth = ref.watch(authControllerProvider);

    return estadoAuth.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const LoginScreen(),
      data: (usuario) => usuario == null ? const LoginScreen() : const Menu(),
    );
  }
}
