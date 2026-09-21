import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/cierre.dart';
import 'package:modelo_sqlite/features/ventas/presentation/providers/venta_providers.dart';

class CierreCajaScreen extends ConsumerStatefulWidget {
  const CierreCajaScreen({super.key});

  @override
  ConsumerState<CierreCajaScreen> createState() => _CierreCajaScreenState();
}

class _CierreCajaScreenState extends ConsumerState<CierreCajaScreen> {
  bool _cerrando = false;

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  String _fmtFechaHora(DateTime d) =>
      '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year} '
      '${_dosDigitos(d.hour)}:${_dosDigitos(d.minute)}';

  Future<void> _confirmarCierre(PeriodoActual periodo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar caja'),
        content: Text(
          '¿Confirmas el cierre?\n\n'
          'Ventas: ${periodo.cantidadVentas}\n'
          'Total: Bs. ${periodo.totalGeneral.toStringAsFixed(2)}\n\n'
          'Esto queda archivado en el historial y el próximo período '
          'comienza desde este momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _cerrando = true);
    try {
      await ref.read(ventaRepositoryProvider).cerrarCaja();
      ref.invalidate(periodoActualProvider);
      ref.invalidate(historialCierresProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Caja cerrada correctamente')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo cerrar caja: $e')));
    } finally {
      if (mounted) setState(() => _cerrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodoAsync = ref.watch(periodoActualProvider);
    final historialAsync = ref.watch(historialCierresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de Caja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Período actual',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          periodoAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'No se pudo cargar el período actual: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
            data: (periodo) {
              return Column(
                children: [
                  Text(
                    'Desde: ${_fmtFechaHora(periodo.fechaInicio)}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _tarjeta('Ventas', '${periodo.cantidadVentas}', Icons.receipt_long),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _tarjeta(
                          'Total',
                          'Bs. ${periodo.totalGeneral.toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _tarjeta(
                          'Efectivo',
                          'Bs. ${periodo.totalEfectivo.toStringAsFixed(2)}',
                          Icons.payments,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _tarjeta(
                          'QR/Transferencia',
                          'Bs. ${periodo.totalQr.toStringAsFixed(2)}',
                          Icons.qr_code,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_cerrando || periodo.cantidadVentas == 0)
                          ? null
                          : () => _confirmarCierre(periodo),
                      icon: const Icon(Icons.lock),
                      label: Text(_cerrando ? 'Cerrando...' : 'Cerrar caja'),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),
          const Text(
            'Historial de cierres',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          historialAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'No se pudo cargar el historial: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
            data: (historial) => historial.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Aún no hay cierres guardados',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Column(
                    children: historial.map((cierre) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orangeAccent.shade200,
                            child: Text(
                              '#${cierre.id}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            'Bs. ${cierre.totalGeneral.toStringAsFixed(2)} · ${cierre.cantidadVentas} ventas',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${_fmtFechaHora(cierre.fechaCierre)} · ${cierre.cerradoPorNombre}\n'
                            'Efectivo: Bs. ${cierre.totalEfectivo.toStringAsFixed(2)} · '
                            'QR: Bs. ${cierre.totalQr.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.orangeAccent, size: 24),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
