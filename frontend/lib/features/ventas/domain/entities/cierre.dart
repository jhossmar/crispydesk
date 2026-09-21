/// The currently open period (since the last Cierre, or the beginning of
/// time if there's never been one). Not yet archived.
class PeriodoActual {
  final DateTime fechaInicio;
  final int cantidadVentas;
  final double totalEfectivo;
  final double totalQr;
  final double totalGeneral;

  const PeriodoActual({
    required this.fechaInicio,
    required this.cantidadVentas,
    required this.totalEfectivo,
    required this.totalQr,
    required this.totalGeneral,
  });

  factory PeriodoActual.fromJson(Map<String, dynamic> json) {
    return PeriodoActual(
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      cantidadVentas: json['cantidadVentas'] as int,
      totalEfectivo: (json['totalEfectivo'] as num).toDouble(),
      totalQr: (json['totalQr'] as num).toDouble(),
      totalGeneral: (json['totalGeneral'] as num).toDouble(),
    );
  }
}

/// An archived closing snapshot.
class Cierre {
  final int id;
  final DateTime fechaInicio;
  final DateTime fechaCierre;
  final int cantidadVentas;
  final double totalEfectivo;
  final double totalQr;
  final double totalGeneral;
  final String cerradoPorNombre;

  const Cierre({
    required this.id,
    required this.fechaInicio,
    required this.fechaCierre,
    required this.cantidadVentas,
    required this.totalEfectivo,
    required this.totalQr,
    required this.totalGeneral,
    required this.cerradoPorNombre,
  });

  factory Cierre.fromJson(Map<String, dynamic> json) {
    return Cierre(
      id: json['id'] as int,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaCierre: DateTime.parse(json['fechaCierre'] as String),
      cantidadVentas: json['cantidadVentas'] as int,
      totalEfectivo: (json['totalEfectivo'] as num).toDouble(),
      totalQr: (json['totalQr'] as num).toDouble(),
      totalGeneral: (json['totalGeneral'] as num).toDouble(),
      cerradoPorNombre: json['cerradoPorNombre'] as String,
    );
  }
}
