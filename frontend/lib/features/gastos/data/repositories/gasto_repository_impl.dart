import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';
import 'package:modelo_sqlite/features/gastos/data/datasources/gasto_remote_datasource.dart';
import 'package:modelo_sqlite/features/gastos/domain/entities/gasto.dart';
import 'package:modelo_sqlite/features/gastos/domain/repositories/gasto_repository.dart';

class GastoRepositoryImpl implements GastoRepository {
  final GastoRemoteDataSource _remoto;
  final AuthRepository _auth;

  GastoRepositoryImpl({required AuthRepository auth, GastoRemoteDataSource? remoto})
    : _remoto = remoto ?? GastoRemoteDataSource(),
      _auth = auth;

  Future<String> _tokenRequerido() async {
    final token = await _auth.obtenerToken();
    if (token == null) {
      throw const GastoException('No hay sesión activa');
    }
    return token;
  }

  @override
  Future<Gasto> registrarGasto({
    required DateTime fecha,
    required String categoria,
    required double monto,
    String? descripcion,
  }) async {
    final token = await _tokenRequerido();
    final json = await _remoto.registrarGasto(
      token: token,
      fecha: fecha,
      categoria: categoria,
      monto: monto,
      descripcion: descripcion,
    );
    return Gasto.fromJson(json);
  }

  @override
  Future<MesGastos> obtenerMes(DateTime mes) async {
    final token = await _tokenRequerido();
    final json = await _remoto.obtenerMes(token: token, mes: mes);
    return MesGastos.fromJson(json);
  }

  @override
  Future<void> eliminarGasto(int id) async {
    final token = await _tokenRequerido();
    await _remoto.eliminarGasto(token: token, id: id);
  }
}
