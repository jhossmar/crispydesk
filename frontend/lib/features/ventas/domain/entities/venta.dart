enum FormaPago {
  efectivo,
  qr,
  mixto;

  static FormaPago fromBackend(String valor) {
    switch (valor) {
      case 'EFECTIVO':
        return FormaPago.efectivo;
      case 'QR':
        return FormaPago.qr;
      case 'MIXTO':
        return FormaPago.mixto;
      default:
        throw ArgumentError('Forma de pago desconocida: $valor');
    }
  }

  String toBackend() => switch (this) {
    FormaPago.efectivo => 'EFECTIVO',
    FormaPago.qr => 'QR',
    FormaPago.mixto => 'MIXTO',
  };

  String get etiqueta => switch (this) {
    FormaPago.efectivo => 'Efectivo',
    FormaPago.qr => 'QR/Transferencia',
    FormaPago.mixto => 'Mixto',
  };
}

class Venta {
  final int id;
  final DateTime fechaVenta;
  final double totalVenta;
  final FormaPago formaPago;
  final double montoEfectivo;
  final double montoQr;

  const Venta({
    required this.id,
    required this.fechaVenta,
    required this.totalVenta,
    required this.formaPago,
    required this.montoEfectivo,
    required this.montoQr,
  });

  double get cambio => montoEfectivo + montoQr - totalVenta;

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] as int,
      fechaVenta: DateTime.parse(json['fechaVenta'] as String),
      totalVenta: (json['totalVenta'] as num).toDouble(),
      formaPago: FormaPago.fromBackend(json['formaPago'] as String),
      montoEfectivo: (json['montoEfectivo'] as num).toDouble(),
      montoQr: (json['montoQr'] as num).toDouble(),
    );
  }
}

class DetalleVenta {
  final int id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? nota;

  const DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.nota,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'] as int,
      ventaId: json['ventaId'] as int,
      productoId: json['productoId'] as int,
      nombreProducto: json['nombreProducto'] as String,
      cantidad: json['cantidad'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      nota: json['nota'] as String?,
    );
  }
}
