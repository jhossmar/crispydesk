import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/database/database_provider.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';
import 'package:modelo_sqlite/features/ventas/data/repositories/venta_repository_impl.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/cierre.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/estadisticas.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/reporte_rango.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/domain/repositories/venta_repository.dart';

final ventaRepositoryProvider = Provider<VentaRepository>((ref) {
  return VentaRepositoryImpl(
    auth: ref.watch(authRepositoryProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

/// Call `ref.invalidate(listaVentasProvider)` after creating/deleting a sale.
final listaVentasProvider = FutureProvider.autoDispose<ResultadoVentas>((ref) {
  return ref.watch(ventaRepositoryProvider).obtenerVentas();
});

final detallesVentaProvider = FutureProvider.autoDispose.family<List<DetalleVenta>, int>((
  ref,
  ventaId,
) {
  return ref.watch(ventaRepositoryProvider).obtenerDetalles(ventaId);
});

final estadisticasProvider = FutureProvider.autoDispose<Estadisticas>((ref) {
  return ref.watch(ventaRepositoryProvider).obtenerEstadisticas();
});

typedef RangoFechas = ({DateTime desde, DateTime hasta});

final reporteRangoProvider = FutureProvider.autoDispose.family<ReporteRango, RangoFechas>((
  ref,
  rango,
) {
  return ref.watch(ventaRepositoryProvider).obtenerReporte(desde: rango.desde, hasta: rango.hasta);
});

final periodoActualProvider = FutureProvider.autoDispose<PeriodoActual>((ref) {
  return ref.watch(ventaRepositoryProvider).obtenerPeriodoActual();
});

final historialCierresProvider = FutureProvider.autoDispose<List<Cierre>>((ref) {
  return ref.watch(ventaRepositoryProvider).obtenerHistorialCierres();
});
