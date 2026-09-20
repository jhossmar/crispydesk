class ModeloVenta {
  int? pkVenta;
  String fechaVenta; // ISO8601
  double totalVenta;

  ModeloVenta({
    this.pkVenta,
    required this.fechaVenta,
    required this.totalVenta,
  });

  Map<String, dynamic> toMap() {
    return {
      'pkVenta': pkVenta,
      'fechaVenta': fechaVenta,
      'totalVenta': totalVenta,
    };
  }

  static ModeloVenta fromMap(Map<String, dynamic> map) {
    return ModeloVenta(
      pkVenta: map['pkVenta'],
      fechaVenta: map['fechaVenta'],
      totalVenta: (map['totalVenta'] as num).toDouble(),
    );
  }
}
