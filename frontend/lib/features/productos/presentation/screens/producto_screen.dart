import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/presentation/providers/producto_providers.dart';
import 'package:modelo_sqlite/features/productos/presentation/widgets/avatar_producto.dart';

class ProductoScreen extends ConsumerStatefulWidget {
  const ProductoScreen({super.key});

  @override
  ConsumerState<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends ConsumerState<ProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreProducto = TextEditingController();
  final _precioUnitario = TextEditingController();
  final _stockInicial = TextEditingController();
  int? _productoActivoId;
  String _categoriaSeleccionada = 'Pollo';
  bool _guardando = false;

  final List<String> _categorias = ['Pollo', 'Bebida', 'Acompañamiento'];
  final _picker = ImagePicker();

  // Foto nueva elegida en este formulario (aún no guardada). Si es null y
  // estamos editando, _imagenExistente conserva la foto que ya tenía el
  // producto para mostrarla en la vista previa.
  Uint8List? _imagenBytesNueva;
  String? _imagenExistente;
  bool _quitarImagen = false;

  Future<void> _elegirImagen() async {
    final archivo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    setState(() {
      _imagenBytesNueva = bytes;
      _quitarImagen = false;
    });
  }

  void _quitarImagenSeleccionada() {
    setState(() {
      _imagenBytesNueva = null;
      _imagenExistente = null;
      _quitarImagen = true;
    });
  }

  /// La foto a enviar al backend: la nueva si se eligió una, o null si no
  /// se tocó nada (el backend conserva la que ya tenía).
  String? get _imagenParaGuardar {
    if (_imagenBytesNueva == null) return null;
    return 'data:image/jpeg;base64,${base64Encode(_imagenBytesNueva!)}';
  }

  // ---------------------------------------------------------------------
  // Alta / edición de DATOS MAESTROS (nombre, categoría, precio).
  // El stock nunca se toca desde acá.
  // ---------------------------------------------------------------------

  Future<void> _grabarProducto() async {
    setState(() => _guardando = true);
    try {
      await ref
          .read(productoRepositoryProvider)
          .crearProducto(
            nombreProducto: _nombreProducto.text.trim(),
            categoria: _categoriaSeleccionada,
            precioProducto: double.tryParse(_precioUnitario.text) ?? 0.0,
            stockProducto: int.tryParse(_stockInicial.text) ?? 0,
            imagen: _imagenParaGuardar,
          );
      _limpiarFormulario();
      ref.invalidate(listaProductosProvider);
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
      await ref
          .read(productoRepositoryProvider)
          .actualizarDatos(
            id: _productoActivoId!,
            nombreProducto: _nombreProducto.text.trim(),
            categoria: _categoriaSeleccionada,
            precioProducto: double.tryParse(_precioUnitario.text) ?? 0.0,
            imagen: _imagenParaGuardar,
            limpiarImagen: _quitarImagen && _imagenBytesNueva == null,
          );
      _limpiarFormulario();
      ref.invalidate(listaProductosProvider);
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
    _productoActivoId = null;
    _imagenBytesNueva = null;
    _imagenExistente = null;
    _quitarImagen = false;
  }

  void _editarCampos(Producto item) {
    _nombreProducto.text = item.nombreProducto;
    _precioUnitario.text = item.precioProducto.toString();
    _categoriaSeleccionada = item.categoria;
    _productoActivoId = item.id;
    _imagenBytesNueva = null;
    _imagenExistente = item.imagen;
    _quitarImagen = false;
  }

  // ---------------------------------------------------------------------
  // Ajuste de STOCK (entrada / salida). Camino separado y explícito,
  // no pasa por el formulario de edición de datos.
  // ---------------------------------------------------------------------

  Future<void> _mostrarDialogoAjusteStock(Producto producto) async {
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
                    decoration: const InputDecoration(labelText: 'Cantidad'),
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
                            await ref
                                .read(productoRepositoryProvider)
                                .ajustarStock(id: producto.id, delta: delta);
                            ref.invalidate(listaProductosProvider);
                            navigator.pop();
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
                              SnackBar(
                                content: Text('No se pudo ajustar el stock: $e'),
                              ),
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

  Future<void> _estaSeguroDeEliminar(Producto objProducto) async {
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
                  await ref
                      .read(productoRepositoryProvider)
                      .eliminarProducto(objProducto.id);
                  ref.invalidate(listaProductosProvider);
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Producto eliminado')),
                  );
                } catch (e) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('No se pudo eliminar el producto: $e')),
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
    final listaAsync = ref.watch(listaProductosProvider);
    final productos = listaAsync.valueOrNull?.productos ?? [];
    final esCache = listaAsync.valueOrNull?.esCache ?? false;
    final editando = _productoActivoId != null;
    final stockActual = editando
        ? productos
              .firstWhere(
                (p) => p.id == _productoActivoId,
                orElse: () => Producto(
                  id: -1,
                  nombreProducto: '',
                  categoria: '',
                  precioProducto: 0,
                  stockProducto: 0,
                ),
              )
              .stockProducto
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Productos (Pollo / Bebidas)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (esCache)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off, size: 18, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin conexión: mostrando datos guardados. No podrás crear ni editar productos hasta reconectarte.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          setState(_limpiarFormulario);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _elegirImagen,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFF1E1E1E),
                        backgroundImage: _imagenBytesNueva != null
                            ? MemoryImage(_imagenBytesNueva!)
                            : decodificarImagenProducto(_imagenExistente) !=
                                  null
                            ? MemoryImage(
                                decodificarImagenProducto(_imagenExistente)!,
                              )
                            : null,
                        child:
                            _imagenBytesNueva == null &&
                                decodificarImagenProducto(_imagenExistente) ==
                                    null
                            ? const Icon(
                                Icons.add_a_photo,
                                color: Colors.white54,
                              )
                            : null,
                      ),
                    ),
                    if (_imagenBytesNueva != null ||
                        decodificarImagenProducto(_imagenExistente) != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _quitarImagenSeleccionada,
                          child: const CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.redAccent,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                          final producto = productos.firstWhere(
                            (p) => p.id == _productoActivoId,
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
                            '$stockActual unid.',
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
                            if (!editando) {
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
                        : (!editando ? 'Registrar' : 'Guardar cambios'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: listaAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : productos.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos registrados',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final item = productos[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: AvatarProducto(producto: item),
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
                                      setState(() => _editarCampos(item));
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
