import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

class Estadisticas extends ConsumerWidget {
  const Estadisticas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticasAsync = ref.watch(estadisticasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(estadisticasProvider.future),
        child: estadisticasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'No se pudieron cargar las estadísticas: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (estadisticas) {
            final ranking = estadisticas.ranking;
            final maxUnidades = ranking.isEmpty ? 1 : ranking.first.totalUnidades;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ------- Estadística 1: resumen del día -------
                const Text(
                  'Resumen de hoy',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TarjetaEstadistica(
                        icono: Icons.point_of_sale,
                        titulo: 'Ventas hoy',
                        valor: '${estadisticas.cantidadHoy}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TarjetaEstadistica(
                        icono: Icons.attach_money,
                        titulo: 'Ingreso hoy',
                        valor: 'Bs. ${estadisticas.totalHoy.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TarjetaEstadistica(
                  icono: Icons.savings,
                  titulo: 'Ingreso histórico total',
                  valor: 'Bs. ${estadisticas.totalHistorico.toStringAsFixed(2)}',
                  ancho: double.infinity,
                ),

                const SizedBox(height: 28),

                // ------- Estadística 2: ranking de productos -------
                const Text(
                  'Productos más vendidos',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (ranking.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Todavía no hay ventas registradas',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ...ranking.map((fila) {
                    final proporcion = fila.totalUnidades / maxUnidades;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fila.nombreProducto,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  '${fila.totalUnidades} unid. · Bs. ${fila.totalIngreso.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: proporcion.clamp(0.02, 1.0),
                                minHeight: 10,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.orangeAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaEstadistica extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final double? ancho;

  const _TarjetaEstadistica({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.ancho,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.orangeAccent, size: 26),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
