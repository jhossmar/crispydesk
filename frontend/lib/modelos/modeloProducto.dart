class ModeloProducto {
  int? pkProducto;
  String nombreProducto;
  String categoria; // 'Pollo' o 'Bebida'
  double precioProducto;
  int stockProducto;

  ModeloProducto({
    this.pkProducto,
    required this.nombreProducto,
    required this.categoria,
    required this.precioProducto,
    required this.stockProducto,
  });

  Map<String, dynamic> toMap() {
    return {
      'pkProducto': pkProducto,
      'nombreProducto': nombreProducto,
      'categoria': categoria,
      'precioProducto': precioProducto,
      'stockProducto': stockProducto,
    };
  }

  static ModeloProducto fromMap(Map<String, dynamic> map) {
    return ModeloProducto(
      pkProducto: map['pkProducto'],
      nombreProducto: map['nombreProducto'],
      categoria: map['categoria'],
      precioProducto: (map['precioProducto'] as num).toDouble(),
      stockProducto: map['stockProducto'],
    );
  }
}
