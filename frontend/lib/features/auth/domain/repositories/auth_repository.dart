import 'package:modelo_sqlite/features/auth/domain/entities/usuario.dart';

class AuthException implements Exception {
  final String mensaje;
  const AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

abstract class AuthRepository {
  /// Calls the backend and, on success, persists the session locally.
  Future<Usuario> login({required String email, required String password});

  /// Clears the locally persisted session.
  Future<void> logout();

  /// Returns the cached session if the stored token is still valid
  /// (verified against the backend), or null if there's no session.
  Future<Usuario?> sesionActual();

  /// Admin-only: creates a new user account. Fails if the current session
  /// isn't an Administrador (enforced by the backend).
  Future<void> crearUsuario({
    required String email,
    required String password,
    required String nombreCompleto,
    required RolUsuario rol,
  });

  /// Admin-only: lists all users.
  Future<List<UsuarioResumen>> listarUsuarios();

  /// Admin-only: activates/deactivates a user.
  Future<void> cambiarEstadoUsuario({required int id, required bool activo});

  /// Admin-only: edits a user's nombreCompleto/email/rol.
  Future<void> actualizarUsuario({
    required int id,
    required String email,
    required String nombreCompleto,
    required RolUsuario rol,
  });

  /// The current session's token, so other features can call protected
  /// backend routes without duplicating secure-storage access. Null if
  /// there's no active session.
  Future<String?> obtenerToken();
}
