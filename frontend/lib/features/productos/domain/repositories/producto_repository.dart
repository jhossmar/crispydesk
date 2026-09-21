import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';

class ProductoException implements Exception {
  final String mensaje;
  const ProductoException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// [esCache] is true when the backend was unreachable and this list came
/// from the local offline cache instead of a live request.
class ResultadoProductos {
  final List<Producto> productos;
  final bool esCache;

  const ResultadoProductos({required this.productos, required this.esCache});
}

abstract class ProductoRepository {
  Future<ResultadoProductos> obtenerProductos();

  Future<Producto> crearProducto({
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
    required int stockProducto,
  });

  /// Edits only nombreProducto/categoria/precioProducto. Stock is handled
  /// exclusively by [ajustarStock].
  Future<Producto> actualizarDatos({
    required int id,
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
  });

  /// Adjusts stock by a signed delta (positive = entrada, negative = salida).
  Future<Producto> ajustarStock({required int id, required int delta});

  Future<void> eliminarProducto(int id);
}
