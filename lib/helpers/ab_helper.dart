import 'package:modelo_sqlite/modelos/modeloProducto.dart';
import 'package:modelo_sqlite/modelos/modeloVenta.dart';
import 'package:modelo_sqlite/modelos/modeloDetalleVenta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  static const String dbName = 'broasteria.db';
  static const int dbVersion = 1;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE producto (
        pkProducto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreProducto TEXT NOT NULL UNIQUE,
        categoria TEXT NOT NULL,
        precioProducto REAL NOT NULL,
        stockProducto INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE venta (
        pkVenta INTEGER PRIMARY KEY AUTOINCREMENT,
        fechaVenta TEXT NOT NULL,
        totalVenta REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE detalle_venta (
        pkDetalle INTEGER PRIMARY KEY AUTOINCREMENT,
        fkVenta INTEGER NOT NULL,
        fkProducto INTEGER NOT NULL,
        nombreProducto TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precioUnitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (fkVenta) REFERENCES venta(pkVenta) ON DELETE CASCADE,
        FOREIGN KEY (fkProducto) REFERENCES producto(pkProducto)
      )
    ''');
  }

  // ---------------------------------------------------------------------
  // CRUD PRODUCTO
  // ---------------------------------------------------------------------

  Future<int> insertaProducto(ModeloProducto producto) async {
    final db = await database;
    return await db.insert('producto', producto.toMap());
  }

  Future<void> eliminarProducto(ModeloProducto producto) async {
    final db = await database;
    await db.delete(
      'producto',
      where: 'pkProducto = ?',
      whereArgs: [producto.pkProducto],
    );
  }

  Future<void> actualizarProducto(ModeloProducto producto, pkProducto) async {
    final db = await database;

    await db.update(
      'producto',
      producto.toMap(),
      where: 'pkProducto = ?',
      whereArgs: [pkProducto],
    );
  }

  // Actualiza SOLO los datos maestros del producto (nombre, categoría, precio).
  // Nunca toca la columna stockProducto: el stock se maneja exclusivamente
  // con ajustarStock(), para que editar datos nunca pise el inventario.
  Future<void> actualizarDatosProducto({
    required int pkProducto,
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
  }) async {
    final db = await database;
    await db.update(
      'producto',
      {
        'nombreProducto': nombreProducto,
        'categoria': categoria,
        'precioProducto': precioProducto,
      },
      where: 'pkProducto = ?',
      whereArgs: [pkProducto],
    );
  }

  Future<List<ModeloProducto>> getProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'producto',
      orderBy: 'nombreProducto ASC',
    );
    return List.generate(maps.length, (i) {
      return ModeloProducto.fromMap(maps[i]);
    });
  }

  Future<bool> existeNombreProducto(String nombreProducto) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'producto',
      columns: ['pkProducto'],
      where: 'nombreProducto = ?',
      whereArgs: [nombreProducto],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Ajusta el stock sumando (o restando si delta es negativo) la cantidad indicada
  Future<void> ajustarStock(int pkProducto, int delta) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE producto SET stockProducto = stockProducto + ? WHERE pkProducto = ?',
      [delta, pkProducto],
    );
  }

  // ---------------------------------------------------------------------
  // VENTA (cabecera + detalle)
  // ---------------------------------------------------------------------

  Future<int> insertaVenta(ModeloVenta venta) async {
    final db = await database;
    return await db.insert('venta', venta.toMap());
  }

  Future<int> insertaDetalleVenta(ModeloDetalleVenta detalle) async {
    final db = await database;
    return await db.insert('detalle_venta', detalle.toMap());
  }

  Future<List<ModeloVenta>> getVentas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'venta',
      orderBy: 'pkVenta DESC',
    );
    return List.generate(maps.length, (i) => ModeloVenta.fromMap(maps[i]));
  }

  Future<List<ModeloDetalleVenta>> getDetallesPorVenta(int pkVenta) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'detalle_venta',
      where: 'fkVenta = ?',
      whereArgs: [pkVenta],
    );
    return List.generate(
      maps.length,
      (i) => ModeloDetalleVenta.fromMap(maps[i]),
    );
  }

  // Elimina una venta (y en cascada sus detalles). Devuelve los detalles
  // que tenía, por si se quiere reponer el stock antes de borrar.
  Future<void> eliminarVenta(int pkVenta) async {
    final db = await database;
    await db.delete('venta', where: 'pkVenta = ?', whereArgs: [pkVenta]);
    // por si el motor no soporta cascade en este build, limpiamos igual
    await db.delete(
      'detalle_venta',
      where: 'fkVenta = ?',
      whereArgs: [pkVenta],
    );
  }

  // ---------------------------------------------------------------------
  // ESTADÍSTICAS
  // ---------------------------------------------------------------------

  // Total en bolivianos vendido en el día de hoy
  Future<double> getTotalVentasHoy() async {
    final db = await database;
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(totalVenta), 0) as total FROM venta WHERE substr(fechaVenta, 1, 10) = ?",
      [hoy],
    );
    return (result.first['total'] as num).toDouble();
  }

  // Cantidad de ventas (comandas) registradas hoy
  Future<int> getCantidadVentasHoy() async {
    final db = await database;
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cantidad FROM venta WHERE substr(fechaVenta, 1, 10) = ?",
      [hoy],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Total histórico de ingresos
  Future<double> getTotalIngresosHistorico() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(totalVenta), 0) as total FROM venta",
    );
    return (result.first['total'] as num).toDouble();
  }

  // Ranking de productos más vendidos (por unidades)
  Future<List<Map<String, dynamic>>> getRankingProductos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT nombreProducto,
             SUM(cantidad) as totalUnidades,
             SUM(subtotal) as totalIngreso
      FROM detalle_venta
      GROUP BY fkProducto
      ORDER BY totalUnidades DESC
    ''');
  }

  // ---------------------------------------------------------------------
  // REPORTES POR FECHA / RANGO DE FECHAS
  // ---------------------------------------------------------------------

  String _inicioDeDia(DateTime fecha) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      0,
      0,
      0,
    ).toIso8601String();
  }

  String _finDeDia(DateTime fecha) {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      23,
      59,
      59,
      999,
    ).toIso8601String();
  }

  // Listado de ventas (cabeceras) dentro de un rango de fechas inclusive.
  Future<List<ModeloVenta>> getVentasPorRango(
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'venta',
      where: 'fechaVenta BETWEEN ? AND ?',
      whereArgs: [_inicioDeDia(desde), _finDeDia(hasta)],
      orderBy: 'pkVenta DESC',
    );
    return List.generate(maps.length, (i) => ModeloVenta.fromMap(maps[i]));
  }

  // Cantidad de ventas + ingreso total dentro de un rango de fechas.
  Future<Map<String, dynamic>> getResumenPorRango(
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as cantidad, COALESCE(SUM(totalVenta), 0) as total
      FROM venta
      WHERE fechaVenta BETWEEN ? AND ?
      ''',
      [_inicioDeDia(desde), _finDeDia(hasta)],
    );
    return {
      'cantidad': (result.first['cantidad'] as int?) ?? 0,
      'total': (result.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // Desglose día por día (cantidad + ingreso) dentro de un rango de fechas.
  Future<List<Map<String, dynamic>>> getResumenDiarioPorRango(
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT substr(fechaVenta, 1, 10) as dia,
             COUNT(*) as cantidad,
             COALESCE(SUM(totalVenta), 0) as total
      FROM venta
      WHERE fechaVenta BETWEEN ? AND ?
      GROUP BY dia
      ORDER BY dia DESC
      ''',
      [_inicioDeDia(desde), _finDeDia(hasta)],
    );
  }

  // Ranking de productos vendidos dentro de un rango de fechas.
  Future<List<Map<String, dynamic>>> getRankingProductosPorRango(
    DateTime desde,
    DateTime hasta,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT d.nombreProducto,
             SUM(d.cantidad) as totalUnidades,
             SUM(d.subtotal) as totalIngreso
      FROM detalle_venta d
      INNER JOIN venta v ON v.pkVenta = d.fkVenta
      WHERE v.fechaVenta BETWEEN ? AND ?
      GROUP BY d.fkProducto
      ORDER BY totalUnidades DESC
      ''',
      [_inicioDeDia(desde), _finDeDia(hasta)],
    );
  }
}
