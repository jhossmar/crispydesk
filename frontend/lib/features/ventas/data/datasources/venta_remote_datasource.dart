import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:modelo_sqlite/core/config/app_config.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/domain/repositories/venta_repository.dart';

class VentaRemoteDataSource {
  final http.Client _client;

  VentaRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> crearVenta({
    required String token,
    required List<ItemVenta> items,
    required FormaPago formaPago,
    required double montoEfectivo,
    required double montoQr,
  }) async {
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/ventas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items
            .map(
              (i) => {'productoId': i.productoId, 'cantidad': i.cantidad, 'nota': i.nota},
            )
            .toList(),
        'formaPago': formaPago.toBackend(),
        'montoEfectivo': montoEfectivo,
        'montoQr': montoQr,
      }),
    );

    if (respuesta.statusCode != 201) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw VentaException(cuerpo['message'] as String? ?? 'No se pudo registrar la venta');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> obtenerVentas(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/ventas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudo obtener el historial de ventas');
    }
    return (jsonDecode(respuesta.body) as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> obtenerDetalles({
    required String token,
    required int ventaId,
  }) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/ventas/$ventaId/detalles'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudo obtener el detalle de la venta');
    }
    return (jsonDecode(respuesta.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> eliminarVenta({required String token, required int id}) async {
    final respuesta = await _client.delete(
      Uri.parse('$backendBaseUrl/ventas/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 204) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw VentaException(cuerpo['message'] as String? ?? 'No se pudo eliminar la venta');
    }
  }

  Future<Map<String, dynamic>> obtenerEstadisticas(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/estadisticas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudieron obtener las estadísticas');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  String _formatoFecha(DateTime fecha) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.year}-${dosDigitos(fecha.month)}-${dosDigitos(fecha.day)}';
  }

  Future<Map<String, dynamic>> obtenerReporte({
    required String token,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final uri = Uri.parse('$backendBaseUrl/reportes').replace(
      queryParameters: {'desde': _formatoFecha(desde), 'hasta': _formatoFecha(hasta)},
    );
    final respuesta = await _client.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudo obtener el reporte');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> obtenerPeriodoActual(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/cierre/actual'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudo obtener el período actual');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cerrarCaja(String token) async {
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/cierre'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 201) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw VentaException(cuerpo['message'] as String? ?? 'No se pudo cerrar caja');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialCierres(String token) async {
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/cierre/historial'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const VentaException('No se pudo obtener el historial de cierres');
    }
    return (jsonDecode(respuesta.body) as List).cast<Map<String, dynamic>>();
  }
}
