import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:modelo_sqlite/features/auth/domain/entities/usuario.dart';
import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

/// Admin user list. Call `ref.invalidate(listaUsuariosProvider)` after
/// creating a user or toggling one's active state to refresh it.
final listaUsuariosProvider = FutureProvider.autoDispose<List<UsuarioResumen>>((ref) {
  return ref.watch(authRepositoryProvider).listarUsuarios();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<Usuario?>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider))..cargarSesion();
    });

class AuthController extends StateNotifier<AsyncValue<Usuario?>> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AsyncValue.loading());

  Future<void> cargarSesion() async {
    state = const AsyncValue.loading();
    try {
      final usuario = await _repo.sesionActual();
      state = AsyncValue.data(usuario);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final usuario = await _repo.login(email: email, password: password);
      state = AsyncValue.data(usuario);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}
