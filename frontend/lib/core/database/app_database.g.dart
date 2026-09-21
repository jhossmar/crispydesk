// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedProductosTable extends CachedProductos
    with TableInfo<$CachedProductosTable, CachedProducto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioProductoMeta = const VerificationMeta(
    'precioProducto',
  );
  @override
  late final GeneratedColumn<double> precioProducto = GeneratedColumn<double>(
    'precio_producto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockProductoMeta = const VerificationMeta(
    'stockProducto',
  );
  @override
  late final GeneratedColumn<int> stockProducto = GeneratedColumn<int>(
    'stock_producto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagenMeta = const VerificationMeta('imagen');
  @override
  late final GeneratedColumn<String> imagen = GeneratedColumn<String>(
    'imagen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombreProducto,
    categoria,
    precioProducto,
    stockProducto,
    imagen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProducto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('precio_producto')) {
      context.handle(
        _precioProductoMeta,
        precioProducto.isAcceptableOrUnknown(
          data['precio_producto']!,
          _precioProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioProductoMeta);
    }
    if (data.containsKey('stock_producto')) {
      context.handle(
        _stockProductoMeta,
        stockProducto.isAcceptableOrUnknown(
          data['stock_producto']!,
          _stockProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockProductoMeta);
    }
    if (data.containsKey('imagen')) {
      context.handle(
        _imagenMeta,
        imagen.isAcceptableOrUnknown(data['imagen']!, _imagenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProducto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProducto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      precioProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_producto'],
      )!,
      stockProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_producto'],
      )!,
      imagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen'],
      ),
    );
  }

  @override
  $CachedProductosTable createAlias(String alias) {
    return $CachedProductosTable(attachedDatabase, alias);
  }
}

class CachedProducto extends DataClass implements Insertable<CachedProducto> {
  final int id;
  final String nombreProducto;
  final String categoria;
  final double precioProducto;
  final int stockProducto;
  final String? imagen;
  const CachedProducto({
    required this.id,
    required this.nombreProducto,
    required this.categoria,
    required this.precioProducto,
    required this.stockProducto,
    this.imagen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['categoria'] = Variable<String>(categoria);
    map['precio_producto'] = Variable<double>(precioProducto);
    map['stock_producto'] = Variable<int>(stockProducto);
    if (!nullToAbsent || imagen != null) {
      map['imagen'] = Variable<String>(imagen);
    }
    return map;
  }

  CachedProductosCompanion toCompanion(bool nullToAbsent) {
    return CachedProductosCompanion(
      id: Value(id),
      nombreProducto: Value(nombreProducto),
      categoria: Value(categoria),
      precioProducto: Value(precioProducto),
      stockProducto: Value(stockProducto),
      imagen: imagen == null && nullToAbsent
          ? const Value.absent()
          : Value(imagen),
    );
  }

  factory CachedProducto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProducto(
      id: serializer.fromJson<int>(json['id']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      categoria: serializer.fromJson<String>(json['categoria']),
      precioProducto: serializer.fromJson<double>(json['precioProducto']),
      stockProducto: serializer.fromJson<int>(json['stockProducto']),
      imagen: serializer.fromJson<String?>(json['imagen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'categoria': serializer.toJson<String>(categoria),
      'precioProducto': serializer.toJson<double>(precioProducto),
      'stockProducto': serializer.toJson<int>(stockProducto),
      'imagen': serializer.toJson<String?>(imagen),
    };
  }

  CachedProducto copyWith({
    int? id,
    String? nombreProducto,
    String? categoria,
    double? precioProducto,
    int? stockProducto,
    Value<String?> imagen = const Value.absent(),
  }) => CachedProducto(
    id: id ?? this.id,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    categoria: categoria ?? this.categoria,
    precioProducto: precioProducto ?? this.precioProducto,
    stockProducto: stockProducto ?? this.stockProducto,
    imagen: imagen.present ? imagen.value : this.imagen,
  );
  CachedProducto copyWithCompanion(CachedProductosCompanion data) {
    return CachedProducto(
      id: data.id.present ? data.id.value : this.id,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      precioProducto: data.precioProducto.present
          ? data.precioProducto.value
          : this.precioProducto,
      stockProducto: data.stockProducto.present
          ? data.stockProducto.value
          : this.stockProducto,
      imagen: data.imagen.present ? data.imagen.value : this.imagen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProducto(')
          ..write('id: $id, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('categoria: $categoria, ')
          ..write('precioProducto: $precioProducto, ')
          ..write('stockProducto: $stockProducto, ')
          ..write('imagen: $imagen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombreProducto,
    categoria,
    precioProducto,
    stockProducto,
    imagen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProducto &&
          other.id == this.id &&
          other.nombreProducto == this.nombreProducto &&
          other.categoria == this.categoria &&
          other.precioProducto == this.precioProducto &&
          other.stockProducto == this.stockProducto &&
          other.imagen == this.imagen);
}

class CachedProductosCompanion extends UpdateCompanion<CachedProducto> {
  final Value<int> id;
  final Value<String> nombreProducto;
  final Value<String> categoria;
  final Value<double> precioProducto;
  final Value<int> stockProducto;
  final Value<String?> imagen;
  const CachedProductosCompanion({
    this.id = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.categoria = const Value.absent(),
    this.precioProducto = const Value.absent(),
    this.stockProducto = const Value.absent(),
    this.imagen = const Value.absent(),
  });
  CachedProductosCompanion.insert({
    this.id = const Value.absent(),
    required String nombreProducto,
    required String categoria,
    required double precioProducto,
    required int stockProducto,
    this.imagen = const Value.absent(),
  }) : nombreProducto = Value(nombreProducto),
       categoria = Value(categoria),
       precioProducto = Value(precioProducto),
       stockProducto = Value(stockProducto);
  static Insertable<CachedProducto> custom({
    Expression<int>? id,
    Expression<String>? nombreProducto,
    Expression<String>? categoria,
    Expression<double>? precioProducto,
    Expression<int>? stockProducto,
    Expression<String>? imagen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (categoria != null) 'categoria': categoria,
      if (precioProducto != null) 'precio_producto': precioProducto,
      if (stockProducto != null) 'stock_producto': stockProducto,
      if (imagen != null) 'imagen': imagen,
    });
  }

  CachedProductosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombreProducto,
    Value<String>? categoria,
    Value<double>? precioProducto,
    Value<int>? stockProducto,
    Value<String?>? imagen,
  }) {
    return CachedProductosCompanion(
      id: id ?? this.id,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      categoria: categoria ?? this.categoria,
      precioProducto: precioProducto ?? this.precioProducto,
      stockProducto: stockProducto ?? this.stockProducto,
      imagen: imagen ?? this.imagen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (precioProducto.present) {
      map['precio_producto'] = Variable<double>(precioProducto.value);
    }
    if (stockProducto.present) {
      map['stock_producto'] = Variable<int>(stockProducto.value);
    }
    if (imagen.present) {
      map['imagen'] = Variable<String>(imagen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProductosCompanion(')
          ..write('id: $id, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('categoria: $categoria, ')
          ..write('precioProducto: $precioProducto, ')
          ..write('stockProducto: $stockProducto, ')
          ..write('imagen: $imagen')
          ..write(')'))
        .toString();
  }
}

class $CachedVentasTable extends CachedVentas
    with TableInfo<$CachedVentasTable, CachedVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaVentaMeta = const VerificationMeta(
    'fechaVenta',
  );
  @override
  late final GeneratedColumn<String> fechaVenta = GeneratedColumn<String>(
    'fecha_venta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalVentaMeta = const VerificationMeta(
    'totalVenta',
  );
  @override
  late final GeneratedColumn<double> totalVenta = GeneratedColumn<double>(
    'total_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formaPagoMeta = const VerificationMeta(
    'formaPago',
  );
  @override
  late final GeneratedColumn<String> formaPago = GeneratedColumn<String>(
    'forma_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoEfectivoMeta = const VerificationMeta(
    'montoEfectivo',
  );
  @override
  late final GeneratedColumn<double> montoEfectivo = GeneratedColumn<double>(
    'monto_efectivo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoQrMeta = const VerificationMeta(
    'montoQr',
  );
  @override
  late final GeneratedColumn<double> montoQr = GeneratedColumn<double>(
    'monto_qr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fechaVenta,
    totalVenta,
    formaPago,
    montoEfectivo,
    montoQr,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha_venta')) {
      context.handle(
        _fechaVentaMeta,
        fechaVenta.isAcceptableOrUnknown(data['fecha_venta']!, _fechaVentaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaVentaMeta);
    }
    if (data.containsKey('total_venta')) {
      context.handle(
        _totalVentaMeta,
        totalVenta.isAcceptableOrUnknown(data['total_venta']!, _totalVentaMeta),
      );
    } else if (isInserting) {
      context.missing(_totalVentaMeta);
    }
    if (data.containsKey('forma_pago')) {
      context.handle(
        _formaPagoMeta,
        formaPago.isAcceptableOrUnknown(data['forma_pago']!, _formaPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_formaPagoMeta);
    }
    if (data.containsKey('monto_efectivo')) {
      context.handle(
        _montoEfectivoMeta,
        montoEfectivo.isAcceptableOrUnknown(
          data['monto_efectivo']!,
          _montoEfectivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoEfectivoMeta);
    }
    if (data.containsKey('monto_qr')) {
      context.handle(
        _montoQrMeta,
        montoQr.isAcceptableOrUnknown(data['monto_qr']!, _montoQrMeta),
      );
    } else if (isInserting) {
      context.missing(_montoQrMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fechaVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_venta'],
      )!,
      totalVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_venta'],
      )!,
      formaPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forma_pago'],
      )!,
      montoEfectivo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_efectivo'],
      )!,
      montoQr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_qr'],
      )!,
    );
  }

  @override
  $CachedVentasTable createAlias(String alias) {
    return $CachedVentasTable(attachedDatabase, alias);
  }
}

class CachedVenta extends DataClass implements Insertable<CachedVenta> {
  final int id;
  final String fechaVenta;
  final double totalVenta;
  final String formaPago;
  final double montoEfectivo;
  final double montoQr;
  const CachedVenta({
    required this.id,
    required this.fechaVenta,
    required this.totalVenta,
    required this.formaPago,
    required this.montoEfectivo,
    required this.montoQr,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha_venta'] = Variable<String>(fechaVenta);
    map['total_venta'] = Variable<double>(totalVenta);
    map['forma_pago'] = Variable<String>(formaPago);
    map['monto_efectivo'] = Variable<double>(montoEfectivo);
    map['monto_qr'] = Variable<double>(montoQr);
    return map;
  }

  CachedVentasCompanion toCompanion(bool nullToAbsent) {
    return CachedVentasCompanion(
      id: Value(id),
      fechaVenta: Value(fechaVenta),
      totalVenta: Value(totalVenta),
      formaPago: Value(formaPago),
      montoEfectivo: Value(montoEfectivo),
      montoQr: Value(montoQr),
    );
  }

  factory CachedVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVenta(
      id: serializer.fromJson<int>(json['id']),
      fechaVenta: serializer.fromJson<String>(json['fechaVenta']),
      totalVenta: serializer.fromJson<double>(json['totalVenta']),
      formaPago: serializer.fromJson<String>(json['formaPago']),
      montoEfectivo: serializer.fromJson<double>(json['montoEfectivo']),
      montoQr: serializer.fromJson<double>(json['montoQr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fechaVenta': serializer.toJson<String>(fechaVenta),
      'totalVenta': serializer.toJson<double>(totalVenta),
      'formaPago': serializer.toJson<String>(formaPago),
      'montoEfectivo': serializer.toJson<double>(montoEfectivo),
      'montoQr': serializer.toJson<double>(montoQr),
    };
  }

  CachedVenta copyWith({
    int? id,
    String? fechaVenta,
    double? totalVenta,
    String? formaPago,
    double? montoEfectivo,
    double? montoQr,
  }) => CachedVenta(
    id: id ?? this.id,
    fechaVenta: fechaVenta ?? this.fechaVenta,
    totalVenta: totalVenta ?? this.totalVenta,
    formaPago: formaPago ?? this.formaPago,
    montoEfectivo: montoEfectivo ?? this.montoEfectivo,
    montoQr: montoQr ?? this.montoQr,
  );
  CachedVenta copyWithCompanion(CachedVentasCompanion data) {
    return CachedVenta(
      id: data.id.present ? data.id.value : this.id,
      fechaVenta: data.fechaVenta.present
          ? data.fechaVenta.value
          : this.fechaVenta,
      totalVenta: data.totalVenta.present
          ? data.totalVenta.value
          : this.totalVenta,
      formaPago: data.formaPago.present ? data.formaPago.value : this.formaPago,
      montoEfectivo: data.montoEfectivo.present
          ? data.montoEfectivo.value
          : this.montoEfectivo,
      montoQr: data.montoQr.present ? data.montoQr.value : this.montoQr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVenta(')
          ..write('id: $id, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('formaPago: $formaPago, ')
          ..write('montoEfectivo: $montoEfectivo, ')
          ..write('montoQr: $montoQr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fechaVenta,
    totalVenta,
    formaPago,
    montoEfectivo,
    montoQr,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVenta &&
          other.id == this.id &&
          other.fechaVenta == this.fechaVenta &&
          other.totalVenta == this.totalVenta &&
          other.formaPago == this.formaPago &&
          other.montoEfectivo == this.montoEfectivo &&
          other.montoQr == this.montoQr);
}

class CachedVentasCompanion extends UpdateCompanion<CachedVenta> {
  final Value<int> id;
  final Value<String> fechaVenta;
  final Value<double> totalVenta;
  final Value<String> formaPago;
  final Value<double> montoEfectivo;
  final Value<double> montoQr;
  const CachedVentasCompanion({
    this.id = const Value.absent(),
    this.fechaVenta = const Value.absent(),
    this.totalVenta = const Value.absent(),
    this.formaPago = const Value.absent(),
    this.montoEfectivo = const Value.absent(),
    this.montoQr = const Value.absent(),
  });
  CachedVentasCompanion.insert({
    this.id = const Value.absent(),
    required String fechaVenta,
    required double totalVenta,
    required String formaPago,
    required double montoEfectivo,
    required double montoQr,
  }) : fechaVenta = Value(fechaVenta),
       totalVenta = Value(totalVenta),
       formaPago = Value(formaPago),
       montoEfectivo = Value(montoEfectivo),
       montoQr = Value(montoQr);
  static Insertable<CachedVenta> custom({
    Expression<int>? id,
    Expression<String>? fechaVenta,
    Expression<double>? totalVenta,
    Expression<String>? formaPago,
    Expression<double>? montoEfectivo,
    Expression<double>? montoQr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fechaVenta != null) 'fecha_venta': fechaVenta,
      if (totalVenta != null) 'total_venta': totalVenta,
      if (formaPago != null) 'forma_pago': formaPago,
      if (montoEfectivo != null) 'monto_efectivo': montoEfectivo,
      if (montoQr != null) 'monto_qr': montoQr,
    });
  }

  CachedVentasCompanion copyWith({
    Value<int>? id,
    Value<String>? fechaVenta,
    Value<double>? totalVenta,
    Value<String>? formaPago,
    Value<double>? montoEfectivo,
    Value<double>? montoQr,
  }) {
    return CachedVentasCompanion(
      id: id ?? this.id,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      totalVenta: totalVenta ?? this.totalVenta,
      formaPago: formaPago ?? this.formaPago,
      montoEfectivo: montoEfectivo ?? this.montoEfectivo,
      montoQr: montoQr ?? this.montoQr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fechaVenta.present) {
      map['fecha_venta'] = Variable<String>(fechaVenta.value);
    }
    if (totalVenta.present) {
      map['total_venta'] = Variable<double>(totalVenta.value);
    }
    if (formaPago.present) {
      map['forma_pago'] = Variable<String>(formaPago.value);
    }
    if (montoEfectivo.present) {
      map['monto_efectivo'] = Variable<double>(montoEfectivo.value);
    }
    if (montoQr.present) {
      map['monto_qr'] = Variable<double>(montoQr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVentasCompanion(')
          ..write('id: $id, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('formaPago: $formaPago, ')
          ..write('montoEfectivo: $montoEfectivo, ')
          ..write('montoQr: $montoQr')
          ..write(')'))
        .toString();
  }
}

class $CachedDetalleVentasTable extends CachedDetalleVentas
    with TableInfo<$CachedDetalleVentasTable, CachedDetalleVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDetalleVentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_ventas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
    subtotal,
    nota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_detalle_ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDetalleVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDetalleVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDetalleVenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
    );
  }

  @override
  $CachedDetalleVentasTable createAlias(String alias) {
    return $CachedDetalleVentasTable(attachedDatabase, alias);
  }
}

class CachedDetalleVenta extends DataClass
    implements Insertable<CachedDetalleVenta> {
  final int id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? nota;
  const CachedDetalleVenta({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    return map;
  }

  CachedDetalleVentasCompanion toCompanion(bool nullToAbsent) {
    return CachedDetalleVentasCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      nombreProducto: Value(nombreProducto),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      subtotal: Value(subtotal),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
    );
  }

  factory CachedDetalleVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDetalleVenta(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      nota: serializer.fromJson<String?>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'productoId': serializer.toJson<int>(productoId),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
      'nota': serializer.toJson<String?>(nota),
    };
  }

  CachedDetalleVenta copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    Value<String?> nota = const Value.absent(),
  }) => CachedDetalleVenta(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId ?? this.productoId,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    subtotal: subtotal ?? this.subtotal,
    nota: nota.present ? nota.value : this.nota,
  );
  CachedDetalleVenta copyWithCompanion(CachedDetalleVentasCompanion data) {
    return CachedDetalleVenta(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDetalleVenta(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
    subtotal,
    nota,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDetalleVenta &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.nombreProducto == this.nombreProducto &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.subtotal == this.subtotal &&
          other.nota == this.nota);
}

class CachedDetalleVentasCompanion extends UpdateCompanion<CachedDetalleVenta> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> productoId;
  final Value<String> nombreProducto;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  final Value<double> subtotal;
  final Value<String?> nota;
  const CachedDetalleVentasCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.nota = const Value.absent(),
  });
  CachedDetalleVentasCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int productoId,
    required String nombreProducto,
    required int cantidad,
    required double precioUnitario,
    required double subtotal,
    this.nota = const Value.absent(),
  }) : ventaId = Value(ventaId),
       productoId = Value(productoId),
       nombreProducto = Value(nombreProducto),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario),
       subtotal = Value(subtotal);
  static Insertable<CachedDetalleVenta> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? productoId,
    Expression<String>? nombreProducto,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
    Expression<double>? subtotal,
    Expression<String>? nota,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (subtotal != null) 'subtotal': subtotal,
      if (nota != null) 'nota': nota,
    });
  }

  CachedDetalleVentasCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaId,
    Value<int>? productoId,
    Value<String>? nombreProducto,
    Value<int>? cantidad,
    Value<double>? precioUnitario,
    Value<double>? subtotal,
    Value<String?>? nota,
  }) {
    return CachedDetalleVentasCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      nota: nota ?? this.nota,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDetalleVentasCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProductosTable cachedProductos = $CachedProductosTable(
    this,
  );
  late final $CachedVentasTable cachedVentas = $CachedVentasTable(this);
  late final $CachedDetalleVentasTable cachedDetalleVentas =
      $CachedDetalleVentasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedProductos,
    cachedVentas,
    cachedDetalleVentas,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_ventas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cached_detalle_ventas', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CachedProductosTableCreateCompanionBuilder =
    CachedProductosCompanion Function({
      Value<int> id,
      required String nombreProducto,
      required String categoria,
      required double precioProducto,
      required int stockProducto,
      Value<String?> imagen,
    });
typedef $$CachedProductosTableUpdateCompanionBuilder =
    CachedProductosCompanion Function({
      Value<int> id,
      Value<String> nombreProducto,
      Value<String> categoria,
      Value<double> precioProducto,
      Value<int> stockProducto,
      Value<String?> imagen,
    });

class $$CachedProductosTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProductosTable> {
  $$CachedProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioProducto => $composableBuilder(
    column: $table.precioProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockProducto => $composableBuilder(
    column: $table.stockProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProductosTable> {
  $$CachedProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioProducto => $composableBuilder(
    column: $table.precioProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockProducto => $composableBuilder(
    column: $table.stockProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProductosTable> {
  $$CachedProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get precioProducto => $composableBuilder(
    column: $table.precioProducto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockProducto => $composableBuilder(
    column: $table.stockProducto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagen =>
      $composableBuilder(column: $table.imagen, builder: (column) => column);
}

class $$CachedProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedProductosTable,
          CachedProducto,
          $$CachedProductosTableFilterComposer,
          $$CachedProductosTableOrderingComposer,
          $$CachedProductosTableAnnotationComposer,
          $$CachedProductosTableCreateCompanionBuilder,
          $$CachedProductosTableUpdateCompanionBuilder,
          (
            CachedProducto,
            BaseReferences<
              _$AppDatabase,
              $CachedProductosTable,
              CachedProducto
            >,
          ),
          CachedProducto,
          PrefetchHooks Function()
        > {
  $$CachedProductosTableTableManager(
    _$AppDatabase db,
    $CachedProductosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<double> precioProducto = const Value.absent(),
                Value<int> stockProducto = const Value.absent(),
                Value<String?> imagen = const Value.absent(),
              }) => CachedProductosCompanion(
                id: id,
                nombreProducto: nombreProducto,
                categoria: categoria,
                precioProducto: precioProducto,
                stockProducto: stockProducto,
                imagen: imagen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombreProducto,
                required String categoria,
                required double precioProducto,
                required int stockProducto,
                Value<String?> imagen = const Value.absent(),
              }) => CachedProductosCompanion.insert(
                id: id,
                nombreProducto: nombreProducto,
                categoria: categoria,
                precioProducto: precioProducto,
                stockProducto: stockProducto,
                imagen: imagen,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedProductosTable, CachedProducto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedProductosTable,
                    CachedProducto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedProductosTable,
      CachedProducto,
      $$CachedProductosTableFilterComposer,
      $$CachedProductosTableOrderingComposer,
      $$CachedProductosTableAnnotationComposer,
      $$CachedProductosTableCreateCompanionBuilder,
      $$CachedProductosTableUpdateCompanionBuilder,
      (
        CachedProducto,
        BaseReferences<_$AppDatabase, $CachedProductosTable, CachedProducto>,
      ),
      CachedProducto,
      PrefetchHooks Function()
    >;
typedef $$CachedVentasTableCreateCompanionBuilder =
    CachedVentasCompanion Function({
      Value<int> id,
      required String fechaVenta,
      required double totalVenta,
      required String formaPago,
      required double montoEfectivo,
      required double montoQr,
    });
typedef $$CachedVentasTableUpdateCompanionBuilder =
    CachedVentasCompanion Function({
      Value<int> id,
      Value<String> fechaVenta,
      Value<double> totalVenta,
      Value<String> formaPago,
      Value<double> montoEfectivo,
      Value<double> montoQr,
    });

final class $$CachedVentasTableReferences
    extends BaseReferences<_$AppDatabase, $CachedVentasTable, CachedVenta> {
  $$CachedVentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CachedDetalleVentasTable,
    List<CachedDetalleVenta>
  >
  _cachedDetalleVentasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cachedDetalleVentas,
        aliasName: 'cached_ventas__id__cached_detalle_ventas__venta_id',
      );

  $$CachedDetalleVentasTableProcessedTableManager get cachedDetalleVentasRefs {
    final manager = $$CachedDetalleVentasTableTableManager(
      $_db,
      $_db.cachedDetalleVentas,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cachedDetalleVentasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedVentasTableFilterComposer
    extends Composer<_$AppDatabase, $CachedVentasTable> {
  $$CachedVentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formaPago => $composableBuilder(
    column: $table.formaPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoEfectivo => $composableBuilder(
    column: $table.montoEfectivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoQr => $composableBuilder(
    column: $table.montoQr,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cachedDetalleVentasRefs(
    Expression<bool> Function($$CachedDetalleVentasTableFilterComposer f) f,
  ) {
    final $$CachedDetalleVentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedDetalleVentas,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedDetalleVentasTableFilterComposer(
            $db: $db,
            $table: $db.cachedDetalleVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedVentasTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedVentasTable> {
  $$CachedVentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPago => $composableBuilder(
    column: $table.formaPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoEfectivo => $composableBuilder(
    column: $table.montoEfectivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoQr => $composableBuilder(
    column: $table.montoQr,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedVentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedVentasTable> {
  $$CachedVentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formaPago =>
      $composableBuilder(column: $table.formaPago, builder: (column) => column);

  GeneratedColumn<double> get montoEfectivo => $composableBuilder(
    column: $table.montoEfectivo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoQr =>
      $composableBuilder(column: $table.montoQr, builder: (column) => column);

  Expression<T> cachedDetalleVentasRefs<T extends Object>(
    Expression<T> Function($$CachedDetalleVentasTableAnnotationComposer a) f,
  ) {
    final $$CachedDetalleVentasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cachedDetalleVentas,
          getReferencedColumn: (t) => t.ventaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedDetalleVentasTableAnnotationComposer(
                $db: $db,
                $table: $db.cachedDetalleVentas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedVentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedVentasTable,
          CachedVenta,
          $$CachedVentasTableFilterComposer,
          $$CachedVentasTableOrderingComposer,
          $$CachedVentasTableAnnotationComposer,
          $$CachedVentasTableCreateCompanionBuilder,
          $$CachedVentasTableUpdateCompanionBuilder,
          (CachedVenta, $$CachedVentasTableReferences),
          CachedVenta,
          PrefetchHooks Function({bool cachedDetalleVentasRefs})
        > {
  $$CachedVentasTableTableManager(_$AppDatabase db, $CachedVentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fechaVenta = const Value.absent(),
                Value<double> totalVenta = const Value.absent(),
                Value<String> formaPago = const Value.absent(),
                Value<double> montoEfectivo = const Value.absent(),
                Value<double> montoQr = const Value.absent(),
              }) => CachedVentasCompanion(
                id: id,
                fechaVenta: fechaVenta,
                totalVenta: totalVenta,
                formaPago: formaPago,
                montoEfectivo: montoEfectivo,
                montoQr: montoQr,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fechaVenta,
                required double totalVenta,
                required String formaPago,
                required double montoEfectivo,
                required double montoQr,
              }) => CachedVentasCompanion.insert(
                id: id,
                fechaVenta: fechaVenta,
                totalVenta: totalVenta,
                formaPago: formaPago,
                montoEfectivo: montoEfectivo,
                montoQr: montoQr,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedVentasTable, CachedVenta>(table),
                  $$CachedVentasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cachedDetalleVentasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cachedDetalleVentasRefs) db.cachedDetalleVentas,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cachedDetalleVentasRefs)
                    await $_getPrefetchedData<
                      CachedVenta,
                      $CachedVentasTable,
                      CachedDetalleVenta
                    >(
                      currentTable: table,
                      referencedTable: $$CachedVentasTableReferences
                          ._cachedDetalleVentasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CachedVentasTableReferences(
                            db,
                            table,
                            p0,
                          ).cachedDetalleVentasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ventaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CachedVentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedVentasTable,
      CachedVenta,
      $$CachedVentasTableFilterComposer,
      $$CachedVentasTableOrderingComposer,
      $$CachedVentasTableAnnotationComposer,
      $$CachedVentasTableCreateCompanionBuilder,
      $$CachedVentasTableUpdateCompanionBuilder,
      (CachedVenta, $$CachedVentasTableReferences),
      CachedVenta,
      PrefetchHooks Function({bool cachedDetalleVentasRefs})
    >;
typedef $$CachedDetalleVentasTableCreateCompanionBuilder =
    CachedDetalleVentasCompanion Function({
      Value<int> id,
      required int ventaId,
      required int productoId,
      required String nombreProducto,
      required int cantidad,
      required double precioUnitario,
      required double subtotal,
      Value<String?> nota,
    });
typedef $$CachedDetalleVentasTableUpdateCompanionBuilder =
    CachedDetalleVentasCompanion Function({
      Value<int> id,
      Value<int> ventaId,
      Value<int> productoId,
      Value<String> nombreProducto,
      Value<int> cantidad,
      Value<double> precioUnitario,
      Value<double> subtotal,
      Value<String?> nota,
    });

final class $$CachedDetalleVentasTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CachedDetalleVentasTable,
          CachedDetalleVenta
        > {
  $$CachedDetalleVentasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedVentasTable _ventaIdTable(_$AppDatabase db) => db.cachedVentas
      .createAlias('cached_detalle_ventas__venta_id__cached_ventas__id');

  $$CachedVentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<int>('venta_id')!;

    final manager = $$CachedVentasTableTableManager(
      $_db,
      $_db.cachedVentas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CachedDetalleVentasTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDetalleVentasTable> {
  $$CachedDetalleVentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedVentasTableFilterComposer get ventaId {
    final $$CachedVentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.cachedVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedVentasTableFilterComposer(
            $db: $db,
            $table: $db.cachedVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedDetalleVentasTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDetalleVentasTable> {
  $$CachedDetalleVentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedVentasTableOrderingComposer get ventaId {
    final $$CachedVentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.cachedVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedVentasTableOrderingComposer(
            $db: $db,
            $table: $db.cachedVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedDetalleVentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDetalleVentasTable> {
  $$CachedDetalleVentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  $$CachedVentasTableAnnotationComposer get ventaId {
    final $$CachedVentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.cachedVentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedVentasTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedVentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedDetalleVentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedDetalleVentasTable,
          CachedDetalleVenta,
          $$CachedDetalleVentasTableFilterComposer,
          $$CachedDetalleVentasTableOrderingComposer,
          $$CachedDetalleVentasTableAnnotationComposer,
          $$CachedDetalleVentasTableCreateCompanionBuilder,
          $$CachedDetalleVentasTableUpdateCompanionBuilder,
          (CachedDetalleVenta, $$CachedDetalleVentasTableReferences),
          CachedDetalleVenta,
          PrefetchHooks Function({bool ventaId})
        > {
  $$CachedDetalleVentasTableTableManager(
    _$AppDatabase db,
    $CachedDetalleVentasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDetalleVentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDetalleVentasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedDetalleVentasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String?> nota = const Value.absent(),
              }) => CachedDetalleVentasCompanion(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
                nota: nota,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaId,
                required int productoId,
                required String nombreProducto,
                required int cantidad,
                required double precioUnitario,
                required double subtotal,
                Value<String?> nota = const Value.absent(),
              }) => CachedDetalleVentasCompanion.insert(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
                nota: nota,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedDetalleVentasTable, CachedDetalleVenta>(
                    table,
                  ),
                  $$CachedDetalleVentasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ventaId,
                        referencedTable: $$CachedDetalleVentasTableReferences
                            ._ventaIdTable(db),
                        referencedColumn: $$CachedDetalleVentasTableReferences
                            ._ventaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CachedDetalleVentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedDetalleVentasTable,
      CachedDetalleVenta,
      $$CachedDetalleVentasTableFilterComposer,
      $$CachedDetalleVentasTableOrderingComposer,
      $$CachedDetalleVentasTableAnnotationComposer,
      $$CachedDetalleVentasTableCreateCompanionBuilder,
      $$CachedDetalleVentasTableUpdateCompanionBuilder,
      (CachedDetalleVenta, $$CachedDetalleVentasTableReferences),
      CachedDetalleVenta,
      PrefetchHooks Function({bool ventaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProductosTableTableManager get cachedProductos =>
      $$CachedProductosTableTableManager(_db, _db.cachedProductos);
  $$CachedVentasTableTableManager get cachedVentas =>
      $$CachedVentasTableTableManager(_db, _db.cachedVentas);
  $$CachedDetalleVentasTableTableManager get cachedDetalleVentas =>
      $$CachedDetalleVentasTableTableManager(_db, _db.cachedDetalleVentas);
}
