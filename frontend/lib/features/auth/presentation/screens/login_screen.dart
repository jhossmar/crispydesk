import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';

/// Cuts a wide downward curve into the bottom edge of a rectangle, used to
/// give the login header its curved shape instead of a plain rectangle.
class _CurvaEncabezado extends CustomClipper<Path> {
  const _CurvaEncabezado();

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 70);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 70);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _iniciarSesion() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final estadoAuth = ref.watch(authControllerProvider);
    final cargando = estadoAuth.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: const _CurvaEncabezado(),
            child: Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade900, Colors.orangeAccent.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant, size: 64, color: Colors.white),
                      const SizedBox(height: 8),
                      const Text(
                        'CrispyDesk',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 190),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Card(
                      color: const Color(0xFF1E1E1E),
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa tu email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'Contraseña'),
                                onFieldSubmitted: (_) => _iniciarSesion(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                              if (estadoAuth.hasError) ...[
                                const SizedBox(height: 14),
                                Text(
                                  estadoAuth.error.toString(),
                                  style: const TextStyle(color: Colors.redAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: cargando ? null : _iniciarSesion,
                                  child: cargando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Ingresar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
