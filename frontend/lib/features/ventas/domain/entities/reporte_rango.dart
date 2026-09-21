import 'package:modelo_sqlite/features/ventas/domain/entities/ranking_producto.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';

class ResumenDiario {
  final String dia; // 'YYYY-MM-DD'
  final int cantidad;
  final double total;

  const ResumenDiario({required this.dia, required this.cantidad, required this.total});

  factory ResumenDiario.fromJson(Map<String, dynamic> json) {
    return ResumenDiario(
      dia: json['dia'] as String,
      cantidad: json['cantidad'] as int,
      total: (json['total'] as num).toDouble(),
    );
  }
}

class ReporteRango {
  final int cantidadVentas;
  final double totalIngreso;
  final List<ResumenDiario> resumenDiario;
  final List<RankingProducto> ranking;
  final List<Venta> ventas;

  const ReporteRango({
    required this.cantidadVentas,
    required this.totalIngreso,
    required this.resumenDiario,
    required this.ranking,
    required this.ventas,
  });

  factory ReporteRango.fromJson(Map<String, dynamic> json) {
    final resumen = json['resumen'] as Map<String, dynamic>;
    return ReporteRango(
      cantidadVentas: resumen['cantidad'] as int,
      totalIngreso: (resumen['total'] as num).toDouble(),
      resumenDiario: (json['diario'] as List)
          .cast<Map<String, dynamic>>()
          .map(ResumenDiario.fromJson)
          .toList(),
      ranking: (json['ranking'] as List)
          .cast<Map<String, dynamic>>()
          .map(RankingProducto.fromJson)
          .toList(),
      ventas: (json['ventas'] as List).cast<Map<String, dynamic>>().map(Venta.fromJson).toList(),
    );
  }
}
