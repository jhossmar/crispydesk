import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modelo_sqlite/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:modelo_sqlite/features/auth/domain/entities/usuario.dart';
import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _claveToken = 'auth_token';

  final AuthRemoteDataSource _remoto;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoto,
    FlutterSecureStorage? storage,
  }) : _remoto = remoto ?? AuthRemoteDataSource(),
       _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Usuario> login({required String email, required String password}) async {
    final respuesta = await _remoto.login(email, password);
    final token = respuesta['token'] as String;
    await _storage.write(key: _claveToken, value: token);
    return Usuario.fromJson(respuesta['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _claveToken);
  }

  @override
  Future<Usuario?> sesionActual() async {
    final token = await _storage.read(key: _claveToken);
    if (token == null) return null;

    try {
      final userJson = await _remoto.perfil(token);
      return Usuario.fromJson(userJson);
    } on AuthException {
      // Token expirado o inválido: limpiamos la sesión guardada.
      await _storage.delete(key: _claveToken);
      return null;
    }
  }

  @override
  Future<void> crearUsuario({
    required String email,
    required String password,
    required String nombreCompleto,
    required RolUsuario rol,
  }) async {
    final token = await _tokenRequerido();
    await _remoto.register(
      token: token,
      email: email,
      password: password,
      nombreCompleto: nombreCompleto,
      rol: rol == RolUsuario.administrador ? 'ADMINISTRADOR' : 'CAJERA',
    );
  }

  Future<String> _tokenRequerido() async {
    final token = await _storage.read(key: _claveToken);
    if (token == null) {
      throw const AuthException('No hay sesión activa');
    }
    return token;
  }

  @override
  Future<List<UsuarioResumen>> listarUsuarios() async {
    final token = await _tokenRequerido();
    final lista = await _remoto.listarUsuarios(token);
    return lista.map(UsuarioResumen.fromJson).toList();
  }

  @override
  Future<void> cambiarEstadoUsuario({required int id, required bool activo}) async {
    final token = await _tokenRequerido();
    await _remoto.cambiarEstadoUsuario(token: token, id: id, activo: activo);
  }

  @override
  Future<void> actualizarUsuario({
    required int id,
    required String email,
    required String nombreCompleto,
    required RolUsuario rol,
  }) async {
    final token = await _tokenRequerido();
    await _remoto.actualizarUsuario(
      token: token,
      id: id,
      email: email,
      nombreCompleto: nombreCompleto,
      rol: rol == RolUsuario.administrador ? 'ADMINISTRADOR' : 'CAJERA',
    );
  }

  @override
  Future<String?> obtenerToken() => _storage.read(key: _claveToken);

  @override
  Future<void> cambiarPassword({
    required int id,
    String? passwordActual,
    required String passwordNueva,
  }) async {
    final token = await _tokenRequerido();
    await _remoto.cambiarPassword(
      token: token,
      id: id,
      passwordActual: passwordActual,
      passwordNueva: passwordNueva,
    );
  }
}
