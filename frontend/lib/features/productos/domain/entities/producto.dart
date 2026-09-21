class Producto {
  final int id;
  final String nombreProducto;
  final String categoria;
  final double precioProducto;
  final int stockProducto;
  final String? imagen;

  const Producto({
    required this.id,
    required this.nombreProducto,
    required this.categoria,
    required this.precioProducto,
    required this.stockProducto,
    this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      nombreProducto: json['nombreProducto'] as String,
      categoria: json['categoria'] as String,
      precioProducto: (json['precioProducto'] as num).toDouble(),
      stockProducto: json['stockProducto'] as int,
      imagen: json['imagen'] as String?,
    );
  }

  // Value equality by id, not object identity. Without this, widgets like
  // DropdownButtonFormField<Producto> break whenever the product list is
  // refetched: a freshly-decoded Producto with the same id is a different
  // object instance, so identity-based `==` would treat it as "not found".
  @override
  bool operator ==(Object other) => other is Producto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
