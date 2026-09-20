class ModeloDetalleVenta {
  int? pkDetalle;
  int fkVenta;
  int fkProducto;
  String nombreProducto;
  int cantidad;
  double precioUnitario;
  double subtotal;

  ModeloDetalleVenta({
    this.pkDetalle,
    required this.fkVenta,
    required this.fkProducto,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'pkDetalle': pkDetalle,
      'fkVenta': fkVenta,
      'fkProducto': fkProducto,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }

  static ModeloDetalleVenta fromMap(Map<String, dynamic> map) {
    return ModeloDetalleVenta(
      pkDetalle: map['pkDetalle'],
      fkVenta: map['fkVenta'],
      fkProducto: map['fkProducto'],
      nombreProducto: map['nombreProducto'],
      cantidad: map['cantidad'],
      precioUnitario: (map['precioUnitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}
