import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:modelo_sqlite/core/config/app_config.dart';
import 'package:modelo_sqlite/features/productos/domain/repositories/producto_repository.dart';

class ProductoRemoteDataSource {
  final http.Client _client;

  ProductoRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<Map<String, dynamic>>> obtenerProductos(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/productos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const ProductoException('No se pudo obtener la lista de productos');
    }
    return (jsonDecode(respuesta.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> crearProducto({
    required String token,
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
    required int stockProducto,
  }) async {
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/productos'),
      headers: _headers(token),
      body: jsonEncode({
        'nombreProducto': nombreProducto,
        'categoria': categoria,
        'precioProducto': precioProducto,
        'stockProducto': stockProducto,
      }),
    );

    if (respuesta.statusCode != 201) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw ProductoException(cuerpo['message'] as String? ?? 'No se pudo crear el producto');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> actualizarDatos({
    required String token,
    required int id,
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
  }) async {
    final respuesta = await _client.patch(
      Uri.parse('$backendBaseUrl/productos/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'nombreProducto': nombreProducto,
        'categoria': categoria,
        'precioProducto': precioProducto,
      }),
    );

    if (respuesta.statusCode != 200) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw ProductoException(cuerpo['message'] as String? ?? 'No se pudo actualizar el producto');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ajustarStock({
    required String token,
    required int id,
    required int delta,
  }) async {
    final respuesta = await _client.patch(
      Uri.parse('$backendBaseUrl/productos/$id/stock'),
      headers: _headers(token),
      body: jsonEncode({'delta': delta}),
    );

    if (respuesta.statusCode != 200) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw ProductoException(cuerpo['message'] as String? ?? 'No se pudo ajustar el stock');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<void> eliminarProducto({required String token, required int id}) async {
    final respuesta = await _client.delete(
      Uri.parse('$backendBaseUrl/productos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 204) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw ProductoException(cuerpo['message'] as String? ?? 'No se pudo eliminar el producto');
    }
  }
}
