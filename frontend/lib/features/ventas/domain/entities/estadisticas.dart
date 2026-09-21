import 'package:modelo_sqlite/features/ventas/domain/entities/ranking_producto.dart';

class Estadisticas {
  final double totalHoy;
  final int cantidadHoy;
  final double totalHistorico;
  final List<RankingProducto> ranking;

  const Estadisticas({
    required this.totalHoy,
    required this.cantidadHoy,
    required this.totalHistorico,
    required this.ranking,
  });

  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      totalHoy: (json['totalHoy'] as num).toDouble(),
      cantidadHoy: json['cantidadHoy'] as int,
      totalHistorico: (json['totalHistorico'] as num).toDouble(),
      ranking: (json['ranking'] as List)
          .cast<Map<String, dynamic>>()
          .map(RankingProducto.fromJson)
          .toList(),
    );
  }
}
