class Gasto {
  final int id;
  final DateTime fecha;
  final String categoria;
  final double monto;
  final String? descripcion;
  final String registradoPorNombre;

  const Gasto({
    required this.id,
    required this.fecha,
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.registradoPorNombre,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      categoria: json['categoria'] as String,
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      registradoPorNombre: json['registradoPorNombre'] as String,
    );
  }
}

class CategoriaGasto {
  final String categoria;
  final double monto;

  const CategoriaGasto({required this.categoria, required this.monto});

  factory CategoriaGasto.fromJson(Map<String, dynamic> json) {
    return CategoriaGasto(
      categoria: json['categoria'] as String,
      monto: (json['monto'] as num).toDouble(),
    );
  }
}

class ResumenGastos {
  final double totalGastos;
  final double totalVentasMes;
  final double gananciaReal;
  final List<CategoriaGasto> porCategoria;

  const ResumenGastos({
    required this.totalGastos,
    required this.totalVentasMes,
    required this.gananciaReal,
    required this.porCategoria,
  });

  factory ResumenGastos.fromJson(Map<String, dynamic> json) {
    return ResumenGastos(
      totalGastos: (json['totalGastos'] as num).toDouble(),
      totalVentasMes: (json['totalVentasMes'] as num).toDouble(),
      gananciaReal: (json['gananciaReal'] as num).toDouble(),
      porCategoria: (json['porCategoria'] as List)
          .cast<Map<String, dynamic>>()
          .map(CategoriaGasto.fromJson)
          .toList(),
    );
  }
}

class MesGastos {
  final List<Gasto> gastos;
  final ResumenGastos resumen;

  const MesGastos({required this.gastos, required this.resumen});

  factory MesGastos.fromJson(Map<String, dynamic> json) {
    return MesGastos(
      gastos: (json['gastos'] as List).cast<Map<String, dynamic>>().map(Gasto.fromJson).toList(),
      resumen: ResumenGastos.fromJson(json['resumen'] as Map<String, dynamic>),
    );
  }
}
