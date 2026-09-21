import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:modelo_sqlite/core/config/app_config.dart';
import 'package:modelo_sqlite/features/gastos/domain/repositories/gasto_repository.dart';

class GastoRemoteDataSource {
  final http.Client _client;

  GastoRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  Future<Map<String, dynamic>> registrarGasto({
    required String token,
    required DateTime fecha,
    required String categoria,
    required double monto,
    String? descripcion,
  }) async {
    final fechaStr =
        '${fecha.year}-${_dosDigitos(fecha.month)}-${_dosDigitos(fecha.day)}';
    final respuesta = await _client.post(
      Uri.parse('$backendBaseUrl/gastos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fecha': fechaStr,
        'categoria': categoria,
        'monto': monto,
        'descripcion': descripcion,
      }),
    );

    if (respuesta.statusCode != 201) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw GastoException(cuerpo['message'] as String? ?? 'No se pudo registrar el gasto');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> obtenerMes({required String token, required DateTime mes}) async {
    final mesStr = '${mes.year}-${_dosDigitos(mes.month)}';
    final respuesta = await _client.get(
      Uri.parse('$backendBaseUrl/gastos').replace(queryParameters: {'mes': mesStr}),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 200) {
      throw const GastoException('No se pudo obtener los gastos del mes');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  Future<void> eliminarGasto({required String token, required int id}) async {
    final respuesta = await _client.delete(
      Uri.parse('$backendBaseUrl/gastos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (respuesta.statusCode != 204) {
      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      throw GastoException(cuerpo['message'] as String? ?? 'No se pudo eliminar el gasto');
    }
  }
}
