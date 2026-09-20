import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';
import 'package:modelo_sqlite/modelos/modeloProducto.dart';

class Producto extends StatefulWidget {
  const Producto({super.key});

  @override
  State<Producto> createState() => _ProductoState();
}

class _ProductoState extends State<Producto> {
  final _formKey = GlobalKey<FormState>();
  final _nombreProducto = TextEditingController();
  final _precioUnitario = TextEditingController();
  final _stockInicial = TextEditingController();
  List<ModeloProducto> _productos = [];
  final _dbHelper = DatabaseHelper();
  String modo = 'grabar';
  int _pkActivo = -1;
  int _stockActualEditando = 0;
  String _categoriaSeleccionada = 'Pollo';
  bool _guardando = false;

  final List<String> _categorias = ['Pollo', 'Bebida'];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productos = await _dbHelper.getProductos();
    setState(() {
      _productos = productos;
      // si estábamos editando este producto, refrescamos el stock mostrado
      if (modo == 'modificar') {
        final actualizado = productos.firstWhere(
          (p) => p.pkProducto == _pkActivo,
          orElse: () => ModeloProducto(
            nombreProducto: '',
            categoria: '',
            precioProducto: 0,
            stockProducto: _stockActualEditando,
          ),
        );
        _stockActualEditando = actualizado.stockProducto;
      }
    });
  }

  // ---------------------------------------------------------------------
  // Alta / edición de DATOS MAESTROS (nombre, categoría, precio).
  // El stock nunca se toca desde acá.
  // ---------------------------------------------------------------------

  Future<void> _grabarProducto() async {
    setState(() => _guardando = true);
    try {
      final nombre = _nombreProducto.text.trim();
      final precio = double.tryParse(_precioUnitario.text) ?? 0.0;
      final stockInicial = int.tryParse(_stockInicial.text) ?? 0;
      final existe = await _dbHelper.existeNombreProducto(nombre);

      if (existe) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error, el nombre ya existe')),
        );
        return;
      }

      final nuevoProducto = ModeloProducto(
        nombreProducto: nombre,
        categoria: _categoriaSeleccionada,
        precioProducto: precio,
        stockProducto: stockInicial,
      );
      await _dbHelper.insertaProducto(nuevoProducto);
      _limpiarFormulario();
      await _cargarProductos();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto registrado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el producto: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _modificarProducto() async {
    setState(() => _guardando = true);
    try {
      final nombre = _nombreProducto.text.trim();
      final precio = double.tryParse(_precioUnitario.text) ?? 0.0;

      // Si el nombre cambió, hay que chequear que no choque con OTRO producto.
      final productoOriginal = _productos.firstWhere(
        (p) => p.pkProducto == _pkActivo,
        orElse: () => ModeloProducto(
          nombreProducto: '',
          categoria: '',
          precioProducto: 0,
          stockProducto: 0,
        ),
      );
      if (nombre != productoOriginal.nombreProducto) {
        final existe = await _dbHelper.existeNombreProducto(nombre);
        if (existe) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe otro producto con ese nombre'),
            ),
          );
          return;
        }
      }

      // Update de solo datos maestros: nombre, categoría, precio.
      // El stock queda intacto pase lo que pase acá.
      await _dbHelper.actualizarDatosProducto(
        pkProducto: _pkActivo,
        nombreProducto: nombre,
        categoria: _categoriaSeleccionada,
        precioProducto: precio,
      );
      _limpiarFormulario();
      await _cargarProductos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se actualizó con éxito')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el producto: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _limpiarFormulario() {
    _nombreProducto.clear();
    _precioUnitario.clear();
    _stockInicial.clear();
    _categoriaSeleccionada = 'Pollo';
    _pkActivo = -1;
    _stockActualEditando = 0;
    modo = 'grabar';
  }

  void _editarCampos(ModeloProducto item) {
    _nombreProducto.text = item.nombreProducto;
    _precioUnitario.text = item.precioProducto.toString();
    _categoriaSeleccionada = item.categoria;
    _stockActualEditando = item.stockProducto;
  }

  // ---------------------------------------------------------------------
  // Ajuste de STOCK (entrada / salida). Camino separado y explícito,
  // no pasa por el formulario de edición de datos.
  // ---------------------------------------------------------------------

  Future<void> _mostrarDialogoAjusteStock(ModeloProducto producto) async {
    final cantidadController = TextEditingController();
    String tipoMovimiento = 'entrada'; // 'entrada' o 'salida'
    bool procesando = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Ajustar stock: ${producto.nombreProducto}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stock actual: ${producto.stockProducto} unidades'),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'entrada',
                        label: Text('Entrada (+)'),
                        icon: Icon(Icons.add_box_outlined),
                      ),
                      ButtonSegment(
                        value: 'salida',
                        label: Text('Salida (-)'),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                    ],
                    selected: {tipoMovimiento},
                    onSelectionChanged: (seleccion) {
                      setDialogState(() {
                        tipoMovimiento = seleccion.first;
                        error = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                    ),
                    onChanged: (_) => setDialogState(() => error = null),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: procesando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: procesando
                      ? null
                      : () async {
                          final cantidad = int.tryParse(
                            cantidadController.text,
                          );
                          if (cantidad == null || cantidad <= 0) {
                            setDialogState(
                              () => error = 'Ingresa una cantidad válida',
                            );
                            return;
                          }
                          if (tipoMovimiento == 'salida' &&
                              cantidad > producto.stockProducto) {
                            setDialogState(
                              () => error =
                                  'No hay suficiente stock (disponible: ${producto.stockProducto})',
                            );
                            return;
                          }

                          setDialogState(() => procesando = true);
                          final delta = tipoMovimiento == 'entrada'
                              ? cantidad
                              : -cantidad;
                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _dbHelper.ajustarStock(
                              producto.pkProducto!,
                              delta,
                            );
                            navigator.pop();
                            await _cargarProductos();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock actualizado: ${producto.stockProducto + delta} unidades',
                                ),
                              ),
                            );
                          } catch (e) {
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text('No se pudo ajustar el stock: $e')),
                            );
                          }
                        },
                  child: procesando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Eliminar producto
  // ---------------------------------------------------------------------

  Future<void> _estaSeguroDeEliminar(ModeloProducto objProducto) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirma eliminar:'),
          content: Text(
            objProducto.nombreProducto,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _dbHelper.eliminarProducto(objProducto);
                  navigator.pop();
                  await _cargarProductos();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Producto eliminado')),
                  );
                } catch (e) {
                  navigator.pop();
                  final esConflicto = e.toString().contains('FOREIGN KEY');
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        esConflicto
                            ? 'No se puede eliminar: este producto tiene ventas registradas.'
                            : 'No se pudo eliminar el producto: $e',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Confirmo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = modo == 'modificar';

    return Scaffold(
      appBar: AppBar(title: const Text('Productos (Pollo / Bebidas)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (editando)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Editando datos del producto. El stock se ajusta aparte.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _limpiarFormulario();
                          setState(() {});
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _nombreProducto,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value ?? 'Pollo';
                  });
                },
              ),
              const SizedBox(height: 14),
              if (!editando)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioUnitario,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Precio (Bs.)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa precio';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _stockInicial,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Stock inicial',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa stock';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed < 0) {
                            return 'Stock inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioUnitario,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Precio (Bs.)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa precio';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final producto = _productos.firstWhere(
                            (p) => p.pkProducto == _pkActivo,
                          );
                          _mostrarDialogoAjusteStock(producto);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Stock actual',
                            suffixIcon: Icon(
                              Icons.swap_vert,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          child: Text(
                            '$_stockActualEditando unid.',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (modo == 'grabar') {
                              _grabarProducto();
                            } else {
                              _modificarProducto();
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                  child: Text(
                    _guardando
                        ? 'Guardando...'
                        : (modo == 'grabar' ? 'Registrar' : 'Guardar cambios'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _productos.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos registrados',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _productos.length,
                        itemBuilder: (context, index) {
                          final item = _productos[index];
                          final esPollo = item.categoria == 'Pollo';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: esPollo
                                    ? Colors.orangeAccent.shade200
                                    : Colors.blueAccent.shade200,
                                child: Icon(
                                  esPollo ? Icons.set_meal : Icons.local_drink,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                item.nombreProducto,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${item.categoria} · Bs. ${item.precioProducto.toStringAsFixed(2)} · Stock: ${item.stockProducto}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Ajustar stock',
                                    onPressed: () =>
                                        _mostrarDialogoAjusteStock(item),
                                    icon: const Icon(
                                      Icons.swap_vert,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Editar datos',
                                    onPressed: () {
                                      setState(() {
                                        _editarCampos(item);
                                        _pkActivo = item.pkProducto!;
                                        modo = 'modificar';
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    onPressed: () {
                                      _estaSeguroDeEliminar(item);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
