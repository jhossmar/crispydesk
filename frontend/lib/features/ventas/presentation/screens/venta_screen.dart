import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/routes/app_routes.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/presentation/providers/producto_providers.dart';
import 'package:modelo_sqlite/features/productos/presentation/widgets/avatar_producto.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/domain/repositories/venta_repository.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

/// A cart line before the sale is confirmed. Not a domain entity - the
/// authoritative price/subtotal only exist once the backend creates the
/// actual DetalleVenta; this is just a local preview built from the
/// product's currently-known price.
class _ItemCarrito {
  final Producto producto;
  final int cantidad;
  final String? corte;

  const _ItemCarrito({required this.producto, required this.cantidad, this.corte});

  double get subtotal => producto.precioProducto * cantidad;
}

const _opcionesCorte = ['Pecho/Ala', 'Pierna/Entrepierna'];

class VentaScreen extends ConsumerStatefulWidget {
  const VentaScreen({super.key});

  @override
  ConsumerState<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends ConsumerState<VentaScreen> {
  final List<_ItemCarrito> _carrito = [];
  // Reassigned (not final) so a fresh empty AnimatedList mounts instantly
  // after a successful sale, instead of animating out every line one by one.
  GlobalKey<AnimatedListState> _carritoListKey = GlobalKey<AnimatedListState>();
  bool _registrando = false;

  FormaPago _formaPago = FormaPago.efectivo;
  final _montoEfectivoController = TextEditingController();
  final _montoQrController = TextEditingController();

  double get _totalCarrito => _carrito.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _montoEfectivo =>
      _formaPago == FormaPago.qr ? 0 : (double.tryParse(_montoEfectivoController.text) ?? 0);

  double get _montoQr =>
      _formaPago == FormaPago.efectivo ? 0 : (double.tryParse(_montoQrController.text) ?? 0);

  double get _cambio => _montoEfectivo + _montoQr - _totalCarrito;

  Future<void> _seleccionarProducto(Producto producto) async {
    if (producto.stockProducto == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sin stock disponible')));
      return;
    }

    final cantidad = await Navigator.pushNamed<int>(
      context,
      AppRoutes.productoCantidad,
      arguments: producto,
    );
    if (cantidad == null) return;
    if (!mounted) return;

    String? corte;
    if (producto.categoria == 'Pollo') {
      corte = await _elegirCorte();
      if (!mounted) return;
    }

    final agregado = _agregarItemACarrito(producto, cantidad, corte: corte);
    if (agregado && producto.categoria == 'Pollo') {
      await _elegirAcompanamiento(cantidad);
    }
  }

  /// Single-choice, skippable. Purely descriptive - carried as a note on
  /// the sale line, doesn't affect stock or price.
  Future<String?> _elegirCorte() async {
    String seleccionado = _opcionesCorte.first;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Elige el corte'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _opcionesCorte.map((opcion) {
                  return RadioListTile<String>(
                    title: Text(opcion),
                    value: opcion,
                    groupValue: seleccionado,
                    onChanged: (value) => setDialogState(() => seleccionado = value!),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Omitir'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, seleccionado),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Adds [producto] x [cantidad] to the cart if there's enough stock left
  /// (accounting for what's already reserved by other cart lines for the
  /// same product). Returns whether it was actually added.
  bool _agregarItemACarrito(Producto producto, int cantidad, {String? corte}) {
    final yaEnCarrito = _carrito
        .where((d) => d.producto.id == producto.id)
        .fold(0, (sum, d) => sum + d.cantidad);

    if (yaEnCarrito + cantidad > producto.stockProducto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente de ${producto.nombreProducto}. '
            'Disponible: ${producto.stockProducto - yaEnCarrito}',
          ),
        ),
      );
      return false;
    }

    setState(() {
      _carrito.add(_ItemCarrito(producto: producto, cantidad: cantidad, corte: corte));
    });
    _carritoListKey.currentState?.insertItem(
      _carrito.length - 1,
      duration: const Duration(milliseconds: 250),
    );
    return true;
  }

  /// Offers a multi-select pick (one, several, or all) from whatever's
  /// currently in stock under the 'Acompañamiento' category. Skips silently
  /// if none exist yet - forcing a picker with no options would be a dead end.
  Future<void> _elegirAcompanamiento(int cantidad) async {
    final productos = ref.read(listaProductosProvider).valueOrNull?.productos ?? [];
    final opciones = productos
        .where((p) => p.categoria == 'Acompañamiento' && p.stockProducto > 0)
        .toList();
    if (opciones.isEmpty) return;

    final seleccionados = <Producto>{};
    final elegidos = await showDialog<Set<Producto>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Elige acompañamiento(s)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: opciones.map((opcion) {
                  return CheckboxListTile(
                    title: Text(opcion.nombreProducto),
                    value: seleccionados.contains(opcion),
                    onChanged: (marcado) {
                      setDialogState(() {
                        if (marcado ?? false) {
                          seleccionados.add(opcion);
                        } else {
                          seleccionados.remove(opcion);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Omitir'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, seleccionados),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (elegidos == null || elegidos.isEmpty || !mounted) return;
    for (final elegido in elegidos) {
      _agregarItemACarrito(elegido, cantidad);
    }
  }

  void _quitarDelCarrito(int index) {
    final item = _carrito.removeAt(index);
    _carritoListKey.currentState?.removeItem(
      index,
      (context, animation) => _construirItemCarrito(item, animation, index),
      duration: const Duration(milliseconds: 250),
    );
    setState(() {});
  }

  Widget _construirItemCarrito(_ItemCarrito item, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(item.producto.nombreProducto, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${item.cantidad} x Bs. ${item.producto.precioProducto.toStringAsFixed(2)}'
              '${item.corte != null ? ' · ${item.corte}' : ''}',
              style: const TextStyle(color: Colors.white60),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bs. ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _quitarDelCarrito(index),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registrarVenta() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Agrega al menos un producto')));
      return;
    }
    if (_montoEfectivo + _montoQr < _totalCarrito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falta dinero: Total Bs. ${_totalCarrito.toStringAsFixed(2)}')),
      );
      return;
    }

    setState(() => _registrando = true);
    try {
      await ref
          .read(ventaRepositoryProvider)
          .crearVenta(
            items: _carrito
                .map(
                  (i) => ItemVenta(productoId: i.producto.id, cantidad: i.cantidad, nota: i.corte),
                )
                .toList(),
            formaPago: _formaPago,
            montoEfectivo: _montoEfectivo,
            montoQr: _montoQr,
          );
      setState(() {
        _carrito.clear();
        _carritoListKey = GlobalKey<AnimatedListState>();
        _montoEfectivoController.clear();
        _montoQrController.clear();
        _formaPago = FormaPago.efectivo;
      });
      ref.invalidate(listaProductosProvider);
      ref.invalidate(listaVentasProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venta registrada con éxito')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo registrar la venta: $e')));
    } finally {
      if (mounted) setState(() => _registrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(listaProductosProvider);
    final productos = productosAsync.valueOrNull?.productos ?? [];
    final esCache = productosAsync.valueOrNull?.esCache ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar venta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                        'Sin conexión: mostrando productos guardados. No podrás confirmar la venta hasta reconectarte.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            if (productosAsync.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (productos.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Primero registra productos en el inventario',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Productos',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 110,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _seleccionarProducto(producto),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'producto-${producto.id}',
                              child: AvatarProducto(producto: producto),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              producto.nombreProducto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              'Bs. ${producto.precioProducto.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pedido actual',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _carrito.isEmpty
                    ? const Center(
                        child: Text(
                          'Aún no agregaste productos',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : AnimatedList(
                        key: _carritoListKey,
                        initialItemCount: _carrito.length,
                        itemBuilder: (context, index, animation) {
                          return _construirItemCarrito(_carrito[index], animation, index);
                        },
                      ),
              ),
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(
                    'Bs. ${_totalCarrito.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SegmentedButton<FormaPago>(
                segments: const [
                  ButtonSegment(value: FormaPago.efectivo, label: Text('Efectivo')),
                  ButtonSegment(value: FormaPago.qr, label: Text('QR')),
                  ButtonSegment(value: FormaPago.mixto, label: Text('Mixto')),
                ],
                selected: {_formaPago},
                onSelectionChanged: (seleccion) {
                  setState(() => _formaPago = seleccion.first);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (_formaPago != FormaPago.qr)
                    Expanded(
                      child: TextFormField(
                        controller: _montoEfectivoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Monto efectivo'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  if (_formaPago == FormaPago.mixto) const SizedBox(width: 10),
                  if (_formaPago != FormaPago.efectivo)
                    Expanded(
                      child: TextFormField(
                        controller: _montoQrController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Monto QR'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                ],
              ),
              if (_montoEfectivo + _montoQr > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _cambio >= 0
                      ? 'Cambio: Bs. ${_cambio.toStringAsFixed(2)}'
                      : 'Faltan: Bs. ${(-_cambio).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _cambio >= 0 ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registrando ? null : _registrarVenta,
                  icon: const Icon(Icons.check_circle),
                  label: Text(_registrando ? 'Registrando...' : 'Confirmar venta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
