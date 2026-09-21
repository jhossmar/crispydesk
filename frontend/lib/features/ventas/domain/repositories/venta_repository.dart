import 'package:modelo_sqlite/features/ventas/domain/entities/cierre.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/estadisticas.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/reporte_rango.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';

class VentaException implements Exception {
  final String mensaje;
  const VentaException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// What the client sends to create a sale line. Price isn't included - the
/// backend reads the current Producto price itself so a stale/tampered
/// client-side price can never be submitted.
class ItemVenta {
  final int productoId;
  final int cantidad;
  final String? nota;

  const ItemVenta({required this.productoId, required this.cantidad, this.nota});
}

/// [esCache] is true when the backend was unreachable and this list came
/// from the local offline cache instead of a live request.
class ResultadoVentas {
  final List<Venta> ventas;
  final bool esCache;

  const ResultadoVentas({required this.ventas, required this.esCache});
}

abstract class VentaRepository {
  Future<Venta> crearVenta({
    required List<ItemVenta> items,
    required FormaPago formaPago,
    required double montoEfectivo,
    required double montoQr,
  });
  Future<ResultadoVentas> obtenerVentas();
  Future<List<DetalleVenta>> obtenerDetalles(int ventaId);
  Future<void> eliminarVenta(int id);

  Future<Estadisticas> obtenerEstadisticas();

  Future<ReporteRango> obtenerReporte({required DateTime desde, required DateTime hasta});

  Future<PeriodoActual> obtenerPeriodoActual();

  Future<Cierre> cerrarCaja();

  Future<List<Cierre>> obtenerHistorialCierres();
}
