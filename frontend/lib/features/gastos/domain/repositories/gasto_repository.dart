import 'package:modelo_sqlite/features/gastos/domain/entities/gasto.dart';

class GastoException implements Exception {
  final String mensaje;
  const GastoException(this.mensaje);

  @override
  String toString() => mensaje;
}

const categoriasGasto = [
  'Luz',
  'Agua',
  'Gas',
  'Alquiler',
  'Sueldos',
  'Insumos/Compras extra',
  'Mantenimiento',
  'Otro',
];

abstract class GastoRepository {
  Future<Gasto> registrarGasto({
    required DateTime fecha,
    required String categoria,
    required double monto,
    String? descripcion,
  });

  /// [mes] can be any date within the target month.
  Future<MesGastos> obtenerMes(DateTime mes);

  Future<void> eliminarGasto(int id);
}
