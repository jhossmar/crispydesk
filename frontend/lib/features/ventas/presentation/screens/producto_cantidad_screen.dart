import 'package:flutter/material.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/presentation/widgets/avatar_producto.dart';

/// Reached from the product GridView in VentaScreen via a Hero transition.
/// Returns the chosen cantidad via `Navigator.pop(context, cantidad)`, or
/// null if the user backs out.
class ProductoCantidadScreen extends StatefulWidget {
  final Producto producto;
  const ProductoCantidadScreen({super.key, required this.producto});

  @override
  State<ProductoCantidadScreen> createState() => _ProductoCantidadScreenState();
}

class _ProductoCantidadScreenState extends State<ProductoCantidadScreen> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final sinStock = producto.stockProducto == 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar al pedido')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: 'producto-${producto.id}',
              child: AvatarProducto(producto: producto, radius: 56, iconSize: 48),
            ),
            const SizedBox(height: 20),
            Text(
              producto.nombreProducto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Bs. ${producto.precioProducto.toStringAsFixed(2)} · Stock: ${producto.stockProducto}',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 32),
            if (sinStock)
              const Text('Sin stock disponible', style: TextStyle(color: Colors.redAccent))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$_cantidad',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _cantidad < producto.stockProducto
                        ? () => setState(() => _cantidad++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: sinStock ? null : () => Navigator.pop(context, _cantidad),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar al pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
