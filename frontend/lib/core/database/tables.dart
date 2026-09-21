import 'package:drift/drift.dart';

/// Local read-cache mirroring the backend's Producto/Venta/DetalleVenta
/// shape. Postgres remains the source of truth for everything; these tables
/// exist purely so Productos and Historial de Ventas stay viewable if the
/// backend is unreachable. Writes always go straight to the backend - there
/// is no offline write queue or conflict resolution here.
class CachedProductos extends Table {
  IntColumn get id => integer()();
  TextColumn get nombreProducto => text()();
  TextColumn get categoria => text()();
  RealColumn get precioProducto => real()();
  IntColumn get stockProducto => integer()();
  TextColumn get imagen => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedVentas extends Table {
  IntColumn get id => integer()();
  TextColumn get fechaVenta => text()();
  RealColumn get totalVenta => real()();
  TextColumn get formaPago => text()();
  RealColumn get montoEfectivo => real()();
  RealColumn get montoQr => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedDetalleVentas extends Table {
  IntColumn get id => integer()();
  IntColumn get ventaId =>
      integer().references(CachedVentas, #id, onDelete: KeyAction.cascade)();
  IntColumn get productoId => integer()();
  TextColumn get nombreProducto => text()();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()();
  RealColumn get subtotal => real()();
  TextColumn get nota => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
