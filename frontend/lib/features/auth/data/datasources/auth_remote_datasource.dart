import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:modelo_sqlite/core/config/app_config.dart';
import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final http.Client _client;

  AuthRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
    if (respuesta.statusCode != 200) {
      throw AuthException(cuerpo['message'] as String? ?? 'No se pudo iniciar sesión');
    }
    return cuerpo;
  }

  /// Verifies a stored token is still valid by hitting the protected /profile route.
  Future<Map<String, dynamic>> perfil(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const AuthException('Sesión expirada');
    }
    final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return cuerpo['user'] as Map<String, dynamic>;
  }

  /// Admin-only: creates a new user. Requires an Administrador's token.
  Future<void> register({
    required String token,
    required String email,
    required String password,
    required String nombreCompleto,
    required String rol,
  }) async {
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'nombreCompleto': nombreCompleto,
        'rol': rol,
      }),
    );

    if (respuesta.statusCode != 201) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw AuthException(cuerpo['message'] as String? ?? 'No se pudo crear el usuario');
    }
  }

  /// Admin-only: lists all users.
  Future<List<Map<String, dynamic>>> listarUsuarios(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const AuthException('No se pudo obtener la lista de usuarios');
    }
    return (jsonDecode(respuesta.body) as List).cast<Map<String, dynamic>>();
  }

  /// Admin-only: activates/deactivates a user.
  Future<void> cambiarEstadoUsuario({
    required String token,
    required int id,
    required bool activo,
  }) async {
    final respuesta = await _client.patch(
      Uri.parse('$backendBaseUrl/users/$id/activo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'activo': activo}),
    );

    if (respuesta.statusCode != 200) {
      throw const AuthException('No se pudo actualizar el estado del usuario');
    }
  }

  /// Admin-only: edits nombreCompleto/email/rol for a user.
  Future<void> actualizarUsuario({
    required String token,
    required int id,
    required String email,
    required String nombreCompleto,
    required String rol,
  }) async {
    final respuesta = await _client.patch(
      Uri.parse('$backendBaseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email, 'nombreCompleto': nombreCompleto, 'rol': rol}),
    );

    if (respuesta.statusCode != 200) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw AuthException(cuerpo['message'] as String? ?? 'No se pudo actualizar el usuario');
    }
  }

  /// Changes a user's password. [passwordActual] is required when changing
  /// one's own password and omitted for an admin's reset of another user's.
  Future<void> cambiarPassword({
    required String token,
    required int id,
    String? passwordActual,
    required String passwordNueva,
  }) async {
    final respuesta = await _client.patch(
      Uri.parse('$backendBaseUrl/users/$id/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (passwordActual != null) 'passwordActual': passwordActual,
        'passwordNueva': passwordNueva,
      }),
    );

    if (respuesta.statusCode != 204) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw AuthException(cuerpo['message'] as String? ?? 'No se pudo cambiar la contraseña');
    }
  }
}
