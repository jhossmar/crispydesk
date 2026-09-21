import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

class DetalleVentaScreen extends ConsumerWidget {
  final Venta venta;
  const DetalleVentaScreen({super.key, required this.venta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detallesAsync = ref.watch(detallesVentaProvider(venta.id));

    return Scaffold(
      appBar: AppBar(title: Text('Detalle venta #${venta.id}')),
      body: Column(
        children: [
          Expanded(
            child: detallesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'No se pudo cargar el detalle: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (detalles) => detalles.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin líneas de detalle',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: detalles.length,
                      itemBuilder: (context, index) {
                        final d = detalles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              d.nombreProducto,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${d.cantidad} x Bs. ${d.precioUnitario.toStringAsFixed(2)}'
                              '${d.nota != null ? ' · ${d.nota}' : ''}',
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: Text(
                              'Bs. ${d.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total venta:', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text(
                      'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Forma de pago: ${venta.formaPago.etiqueta}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                if (venta.montoEfectivo > 0)
                  Text(
                    'Efectivo: Bs. ${venta.montoEfectivo.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                if (venta.montoQr > 0)
                  Text(
                    'QR: Bs. ${venta.montoQr.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
