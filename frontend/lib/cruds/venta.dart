import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';
import 'package:modelo_sqlite/modelos/modeloProducto.dart';
import 'package:modelo_sqlite/modelos/modeloVenta.dart';
import 'package:modelo_sqlite/modelos/modeloDetalleVenta.dart';

class Venta extends StatefulWidget {
  const Venta({super.key});

  @override
  State<Venta> createState() => _VentaState();
}

class _VentaState extends State<Venta> {
  final _dbHelper = DatabaseHelper();
  List<ModeloProducto> _productos = [];
  ModeloProducto? _productoSeleccionado;
  final _cantidadController = TextEditingController(text: '1');

  // carrito temporal, aún no guardado
  final List<ModeloDetalleVenta> _carrito = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productos = await _dbHelper.getProductos();
    setState(() {
      _productos = productos;
      if (productos.isNotEmpty) {
        _productoSeleccionado = productos.first;
      }
    });
  }

  double get _totalCarrito =>
      _carrito.fold(0.0, (sum, item) => sum + item.subtotal);

  void _agregarAlCarrito() {
    if (_productoSeleccionado == null) return;
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una cantidad válida')),
      );
      return;
    }

    // cantidad ya reservada en el carrito para este producto
    final yaEnCarrito = _carrito
        .where((d) => d.fkProducto == _productoSeleccionado!.pkProducto)
        .fold(0, (sum, d) => sum + d.cantidad);

    if (yaEnCarrito + cantidad > _productoSeleccionado!.stockProducto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. Disponible: ${_productoSeleccionado!.stockProducto - yaEnCarrito}',
          ),
        ),
      );
      return;
    }

    setState(() {
      _carrito.add(
        ModeloDetalleVenta(
          fkVenta: 0,
          fkProducto: _productoSeleccionado!.pkProducto!,
          nombreProducto: _productoSeleccionado!.nombreProducto,
          cantidad: cantidad,
          precioUnitario: _productoSeleccionado!.precioProducto,
          subtotal: cantidad * _productoSeleccionado!.precioProducto,
        ),
      );
      _cantidadController.text = '1';
    });
  }

  void _quitarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  Future<void> _registrarVenta() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }

    final nuevaVenta = ModeloVenta(
      fechaVenta: DateTime.now().toIso8601String(),
      totalVenta: _totalCarrito,
    );
    final pkVenta = await _dbHelper.insertaVenta(nuevaVenta);

    for (final detalle in _carrito) {
      detalle.fkVenta = pkVenta;
      await _dbHelper.insertaDetalleVenta(detalle);
      await _dbHelper.ajustarStock(detalle.fkProducto, -detalle.cantidad);
    }

    setState(() {
      _carrito.clear();
    });
    await _cargarProductos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta registrada con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar venta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_productos.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Primero registra productos en el inventario',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<ModeloProducto>(
                      value: _productoSeleccionado,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Producto'),
                      items: _productos
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.nombreProducto} (Bs. ${p.precioProducto.toStringAsFixed(2)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _productoSeleccionado = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cantidadController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Cant.'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _agregarAlCarrito,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar al pedido'),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pedido actual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                    : ListView.builder(
                        itemCount: _carrito.length,
                        itemBuilder: (context, index) {
                          final item = _carrito[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                item.nombreProducto,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${item.cantidad} x Bs. ${item.precioUnitario.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Bs. ${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _quitarDelCarrito(index),
                                    icon: const Icon(
                                      Icons.close,
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
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registrarVenta,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar venta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
