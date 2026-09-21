class RankingProducto {
  final String nombreProducto;
  final int totalUnidades;
  final double totalIngreso;

  const RankingProducto({
    required this.nombreProducto,
    required this.totalUnidades,
    required this.totalIngreso,
  });

  factory RankingProducto.fromJson(Map<String, dynamic> json) {
    return RankingProducto(
      nombreProducto: json['nombreProducto'] as String,
      totalUnidades: json['totalUnidades'] as int,
      totalIngreso: (json['totalIngreso'] as num).toDouble(),
    );
  }
}
