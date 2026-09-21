import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' show ClientException;
import 'package:modelo_sqlite/core/database/app_database.dart';
import 'package:modelo_sqlite/features/auth/domain/repositories/auth_repository.dart';
import 'package:modelo_sqlite/features/productos/data/datasources/producto_remote_datasource.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/domain/repositories/producto_repository.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoRemoteDataSource _remoto;
  final AuthRepository _auth;
  final AppDatabase _db;

  ProductoRepositoryImpl({
    required AuthRepository auth,
    required AppDatabase db,
    ProductoRemoteDataSource? remoto,
  }) : _remoto = remoto ?? ProductoRemoteDataSource(),
       _auth = auth,
       _db = db;

  Future<String> _tokenRequerido() async {
    final token = await _auth.obtenerToken();
    if (token == null) {
      throw const ProductoException('No hay sesión activa');
    }
    return token;
  }

  @override
  Future<ResultadoProductos> obtenerProductos() async {
    final token = await _tokenRequerido();
    try {
      final lista = await _remoto.obtenerProductos(token);
      final productos = lista.map(Producto.fromJson).toList();
      await _guardarEnCache(productos);
      return ResultadoProductos(productos: productos, esCache: false);
    } on ClientException {
      // Backend unreachable: fall back to whatever was cached from the last
      // successful fetch. If there's nothing cached (e.g. first run ever
      // happens offline), there's nothing useful to fall back to.
      final cacheados = await _leerDeCache();
      if (cacheados.isEmpty) rethrow;
      return ResultadoProductos(productos: cacheados, esCache: true);
    }
  }

  /// Replaces the whole cache with [productos] so deletions on the backend
  /// also disappear from the cache, not just updates/creates.
  Future<void> _guardarEnCache(List<Producto> productos) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedProductos).go();
      for (final producto in productos) {
        await _db
            .into(_db.cachedProductos)
            .insert(
              CachedProductosCompanion.insert(
                id: Value(producto.id),
                nombreProducto: producto.nombreProducto,
                categoria: producto.categoria,
                precioProducto: producto.precioProducto,
                stockProducto: producto.stockProducto,
                imagen: Value(producto.imagen),
              ),
            );
      }
    });
  }

  Future<List<Producto>> _leerDeCache() async {
    final filas = await _db.select(_db.cachedProductos).get();
    return filas
        .map(
          (f) => Producto(
            id: f.id,
            nombreProducto: f.nombreProducto,
            categoria: f.categoria,
            precioProducto: f.precioProducto,
            stockProducto: f.stockProducto,
            imagen: f.imagen,
          ),
        )
        .toList();
  }

  @override
  Future<Producto> crearProducto({
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
    required int stockProducto,
    String? imagen,
  }) async {
    final token = await _tokenRequerido();
    final json = await _remoto.crearProducto(
      token: token,
      nombreProducto: nombreProducto,
      categoria: categoria,
      precioProducto: precioProducto,
      stockProducto: stockProducto,
      imagen: imagen,
    );
    return Producto.fromJson(json);
  }

  @override
  Future<Producto> actualizarDatos({
    required int id,
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
    String? imagen,
    bool limpiarImagen = false,
  }) async {
    final token = await _tokenRequerido();
    final json = await _remoto.actualizarDatos(
      token: token,
      id: id,
      nombreProducto: nombreProducto,
      categoria: categoria,
      precioProducto: precioProducto,
      imagen: imagen,
      limpiarImagen: limpiarImagen,
    );
    return Producto.fromJson(json);
  }

  @override
  Future<Producto> ajustarStock({required int id, required int delta}) async {
    final token = await _tokenRequerido();
    final json = await _remoto.ajustarStock(token: token, id: id, delta: delta);
    return Producto.fromJson(json);
  }

  @override
  Future<void> eliminarProducto(int id) async {
    final token = await _tokenRequerido();
    await _remoto.eliminarProducto(token: token, id: id);
  }
}
