import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' show ClientException;
import 'package:modelo_sqlite/core/database/app_database.dart';
import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';
import 'package:modelo_sqlite/features/ventas/data/datasources/venta_remote_datasource.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/cierre.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/estadisticas.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/reporte_rango.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/domain/repositories/venta_repository.dart';

class VentaRepositoryImpl implements VentaRepository {
  final VentaRemoteDataSource _remoto;
  final AuthRepository _auth;
  final AppDatabase _db;

  VentaRepositoryImpl({
    required AuthRepository auth,
    required AppDatabase db,
    VentaRemoteDataSource? remoto,
  }) : _remoto = remoto ?? VentaRemoteDataSource(),
       _auth = auth,
       _db = db;

  Future<String> _tokenRequerido() async {
    final token = await _auth.obtenerToken();
    if (token == null) {
      throw const VentaException('No hay sesión activa');
    }
    return token;
  }

  @override
  Future<Venta> crearVenta({
    required List<ItemVenta> items,
    required FormaPago formaPago,
    required double montoEfectivo,
    required double montoQr,
  }) async {
    final token = await _tokenRequerido();
    final json = await _remoto.crearVenta(
      token: token,
      items: items,
      formaPago: formaPago,
      montoEfectivo: montoEfectivo,
      montoQr: montoQr,
    );
    return Venta.fromJson(json);
  }

  @override
  Future<ResultadoVentas> obtenerVentas() async {
    final token = await _tokenRequerido();
    try {
      final lista = await _remoto.obtenerVentas(token);
      final ventas = lista.map(Venta.fromJson).toList();
      await _guardarVentasEnCache(ventas);
      return ResultadoVentas(ventas: ventas, esCache: false);
    } on ClientException {
      final cacheadas = await _leerVentasDeCache();
      if (cacheadas.isEmpty) rethrow;
      return ResultadoVentas(ventas: cacheadas, esCache: true);
    }
  }

  Future<void> _guardarVentasEnCache(List<Venta> ventas) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedVentas).go();
      for (final venta in ventas) {
        await _db
            .into(_db.cachedVentas)
            .insert(
              CachedVentasCompanion.insert(
                id: Value(venta.id),
                fechaVenta: venta.fechaVenta.toIso8601String(),
                totalVenta: venta.totalVenta,
                formaPago: venta.formaPago.toBackend(),
                montoEfectivo: venta.montoEfectivo,
                montoQr: venta.montoQr,
              ),
            );
      }
    });
  }

  Future<List<Venta>> _leerVentasDeCache() async {
    final filas = await _db.select(_db.cachedVentas).get();
    return filas
        .map(
          (f) => Venta(
            id: f.id,
            fechaVenta: DateTime.parse(f.fechaVenta),
            totalVenta: f.totalVenta,
            formaPago: FormaPago.fromBackend(f.formaPago),
            montoEfectivo: f.montoEfectivo,
            montoQr: f.montoQr,
          ),
        )
        .toList();
  }

  @override
  Future<List<DetalleVenta>> obtenerDetalles(int ventaId) async {
    final token = await _tokenRequerido();
    try {
      final lista = await _remoto.obtenerDetalles(token: token, ventaId: ventaId);
      final detalles = lista.map(DetalleVenta.fromJson).toList();
      await _guardarDetallesEnCache(ventaId, detalles);
      return detalles;
    } on ClientException {
      final cacheados = await _leerDetallesDeCache(ventaId);
      if (cacheados.isEmpty) rethrow;
      return cacheados;
    }
  }

  Future<void> _guardarDetallesEnCache(int ventaId, List<DetalleVenta> detalles) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.cachedDetalleVentas,
      )..where((t) => t.ventaId.equals(ventaId))).go();
      for (final detalle in detalles) {
        await _db
            .into(_db.cachedDetalleVentas)
            .insert(
              CachedDetalleVentasCompanion.insert(
                id: Value(detalle.id),
                ventaId: detalle.ventaId,
                productoId: detalle.productoId,
                nombreProducto: detalle.nombreProducto,
                cantidad: detalle.cantidad,
                precioUnitario: detalle.precioUnitario,
                subtotal: detalle.subtotal,
                nota: Value(detalle.nota),
              ),
            );
      }
    });
  }

  Future<List<DetalleVenta>> _leerDetallesDeCache(int ventaId) async {
    final filas =
        await (_db.select(
          _db.cachedDetalleVentas,
        )..where((t) => t.ventaId.equals(ventaId))).get();
    return filas
        .map(
          (f) => DetalleVenta(
            id: f.id,
            ventaId: f.ventaId,
            productoId: f.productoId,
            nombreProducto: f.nombreProducto,
            cantidad: f.cantidad,
            precioUnitario: f.precioUnitario,
            subtotal: f.subtotal,
            nota: f.nota,
          ),
        )
        .toList();
  }

  @override
  Future<void> eliminarVenta(int id) async {
    final token = await _tokenRequerido();
    await _remoto.eliminarVenta(token: token, id: id);
  }

  @override
  Future<Estadisticas> obtenerEstadisticas() async {
    final token = await _tokenRequerido();
    final json = await _remoto.obtenerEstadisticas(token);
    return Estadisticas.fromJson(json);
  }

  @override
  Future<ReporteRango> obtenerReporte({required DateTime desde, required DateTime hasta}) async {
    final token = await _tokenRequerido();
    final json = await _remoto.obtenerReporte(token: token, desde: desde, hasta: hasta);
    return ReporteRango.fromJson(json);
  }

  @override
  Future<PeriodoActual> obtenerPeriodoActual() async {
    final token = await _tokenRequerido();
    final json = await _remoto.obtenerPeriodoActual(token);
    return PeriodoActual.fromJson(json);
  }

  @override
  Future<Cierre> cerrarCaja() async {
    final token = await _tokenRequerido();
    final json = await _remoto.cerrarCaja(token);
    return Cierre.fromJson(json);
  }

  @override
  Future<List<Cierre>> obtenerHistorialCierres() async {
    final token = await _tokenRequerido();
    final lista = await _remoto.obtenerHistorialCierres(token);
    return lista.map(Cierre.fromJson).toList();
  }
}
