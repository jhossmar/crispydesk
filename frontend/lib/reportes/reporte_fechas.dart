import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/routes/app_routes.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

/// Reporte de ventas administrable por día o por rango de fechas.
/// Muestra: resumen (cantidad + ingreso), desglose día por día,
/// ranking de productos del rango y el listado de ventas incluidas.
class ReporteFechas extends ConsumerStatefulWidget {
  const ReporteFechas({super.key});

  @override
  ConsumerState<ReporteFechas> createState() => _ReporteFechasState();
}

class _ReporteFechasState extends ConsumerState<ReporteFechas> {
  DateTime _desde = DateTime.now();
  DateTime _hasta = DateTime.now();

  void _fijarRango(DateTime desde, DateTime hasta) {
    setState(() {
      _desde = desde;
      _hasta = hasta;
    });
  }

  void _hoy() {
    final hoy = DateTime.now();
    _fijarRango(hoy, hoy);
  }

  void _ayer() {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    _fijarRango(ayer, ayer);
  }

  void _ultimos7Dias() {
    final hoy = DateTime.now();
    _fijarRango(hoy.subtract(const Duration(days: 6)), hoy);
  }

  void _esteMes() {
    final hoy = DateTime.now();
    _fijarRango(DateTime(hoy.year, hoy.month, 1), hoy);
  }

  Future<void> _elegirFecha({required bool esDesde}) async {
    final inicial = esDesde ? _desde : _hasta;
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (seleccionada == null) return;

    setState(() {
      if (esDesde) {
        _desde = seleccionada;
        if (_hasta.isBefore(_desde)) _hasta = _desde;
      } else {
        _hasta = seleccionada;
        if (_desde.isAfter(_hasta)) _desde = _hasta;
      }
    });
  }

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  String _fmtFecha(DateTime d) => '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year}';

  String _fmtFechaHora(DateTime d) =>
      '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year} '
      '${_dosDigitos(d.hour)}:${_dosDigitos(d.minute)}';

  // 'dia' viene como 'YYYY-MM-DD' desde el backend
  String _fmtDiaCorto(String isoDia) {
    final partes = isoDia.split('-');
    return '${partes[2]}/${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final rango = (desde: _desde, hasta: _hasta);
    final reporteAsync = ref.watch(reporteRangoProvider(rango));

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte por fecha')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(reporteRangoProvider(rango).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _elegirFecha(esDesde: true),
                    child: Text('Desde: ${_fmtFecha(_desde)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _elegirFecha(esDesde: false),
                    child: Text('Hasta: ${_fmtFecha(_hasta)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(label: const Text('Hoy'), onPressed: _hoy),
                ActionChip(label: const Text('Ayer'), onPressed: _ayer),
                ActionChip(label: const Text('Últimos 7 días'), onPressed: _ultimos7Dias),
                ActionChip(label: const Text('Este mes'), onPressed: _esteMes),
              ],
            ),
            const SizedBox(height: 20),

            reporteAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No se pudo cargar el reporte: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (reporte) {
                final promedio = reporte.cantidadVentas == 0
                    ? 0.0
                    : reporte.totalIngreso / reporte.cantidadVentas;
                final maxDiario = reporte.resumenDiario.isEmpty
                    ? 1.0
                    : reporte.resumenDiario.fold<double>(1.0, (a, b) => a > b.total ? a : b.total);

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _tarjeta(
                            'Ventas',
                            '${reporte.cantidadVentas}',
                            Icons.point_of_sale,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _tarjeta(
                            'Ingreso',
                            'Bs. ${reporte.totalIngreso.toStringAsFixed(2)}',
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _tarjeta(
                      'Promedio por venta',
                      'Bs. ${promedio.toStringAsFixed(2)}',
                      Icons.trending_up,
                      ancho: double.infinity,
                    ),

                    const SizedBox(height: 26),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Desglose por día',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (reporte.resumenDiario.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Sin ventas en este rango',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      ...reporte.resumenDiario.map((fila) {
                        final proporcion = (fila.total / maxDiario).clamp(0.02, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fmtDiaCorto(fila.dia),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${fila.cantidad} ventas · Bs. ${fila.total.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white60),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: proporcion,
                                  minHeight: 8,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 26),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Productos vendidos en el rango',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (reporte.ranking.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Sin ventas en este rango',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      ...reporte.ranking.map((fila) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              fila.nombreProducto,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              '${fila.totalUnidades} unid. · Bs. ${fila.totalIngreso.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.orangeAccent),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ventas del rango',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${reporte.ventas.length}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (reporte.ventas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Sin ventas en este rango',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      ...reporte.ventas.map((venta) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orangeAccent.shade200,
                              child: Text(
                                '#${venta.id}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              _fmtFechaHora(venta.fechaVenta),
                              style: const TextStyle(color: Colors.white60),
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
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono, {double? ancho}) {
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
