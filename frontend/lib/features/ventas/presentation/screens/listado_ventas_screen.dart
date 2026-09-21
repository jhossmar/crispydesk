import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/routes/app_routes.dart';
import 'package:modelo_sqlite/features/productos/presentation/providers/producto_providers.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

class ListadoVentasScreen extends ConsumerWidget {
  const ListadoVentasScreen({super.key});

  String _formatearFecha(DateTime fecha) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year} '
        '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}';
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    Venta venta,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar venta'),
          content: Text(
            '¿Eliminar la venta #${venta.id} por Bs. ${venta.totalVenta.toStringAsFixed(2)}?\n'
            'Se repondrá el stock de los productos vendidos.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref
                      .read(ventaRepositoryProvider)
                      .eliminarVenta(venta.id);
                  ref.invalidate(listaVentasProvider);
                  ref.invalidate(listaProductosProvider);
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Venta eliminada')),
                  );
                } catch (e) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('No se pudo eliminar la venta: $e')),
                  );
                }
              },
              child: const Text('Confirmo'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasAsync = ref.watch(listaVentasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de ventas')),
      body: ventasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'No se pudo cargar el historial: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (resultado) {
          final ventas = resultado.ventas;
          return Column(
            children: [
              if (resultado.esCache)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
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
                          'Sin conexión: mostrando historial guardado.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ventas.isEmpty
                    ? const Center(
                        child: Text(
                          'Aún no hay ventas registradas',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: ventas.length,
                        itemBuilder: (context, index) {
                          final venta = ventas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orangeAccent.shade200,
                                child: Text(
                                  '#${venta.id}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${_formatearFecha(venta.fechaVenta)} · ${venta.formaPago.etiqueta}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              trailing: IconButton(
                                onPressed: () =>
                                    _confirmarEliminar(context, ref, venta),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detalleVenta,
                                  arguments: venta,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
