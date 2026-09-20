import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';
import 'package:modelo_sqlite/modelos/modeloVenta.dart';
import 'package:modelo_sqlite/listados/detalle_venta.dart';

class ListadoVentas extends StatefulWidget {
  const ListadoVentas({super.key});

  @override
  State<ListadoVentas> createState() => _ListadoVentasState();
}

class _ListadoVentasState extends State<ListadoVentas> {
  final _dbHelper = DatabaseHelper();
  List<ModeloVenta> _ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final ventas = await _dbHelper.getVentas();
    setState(() {
      _ventas = ventas;
    });
  }

  String _formatearFecha(String isoFecha) {
    final fecha = DateTime.parse(isoFecha);
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year} '
        '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}';
  }

  Future<void> _confirmarEliminar(ModeloVenta venta) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar venta'),
          content: Text(
            '¿Eliminar la venta #${venta.pkVenta} por Bs. ${venta.totalVenta.toStringAsFixed(2)}?\n'
            'Se repondrá el stock de los productos vendidos.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // repone stock antes de borrar
                final detalles = await _dbHelper.getDetallesPorVenta(
                  venta.pkVenta!,
                );
                for (final d in detalles) {
                  await _dbHelper.ajustarStock(d.fkProducto, d.cantidad);
                }
                await _dbHelper.eliminarVenta(venta.pkVenta!);
                if (!context.mounted) return;
                Navigator.pop(context);
                _cargarVentas();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta eliminada')),
                );
              },
              child: const Text('Confirmo'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de ventas')),
      body: _ventas.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay ventas registradas',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _ventas.length,
              itemBuilder: (context, index) {
                final venta = _ventas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orangeAccent.shade200,
                      child: Text(
                        '#${venta.pkVenta}',
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
                      _formatearFecha(venta.fechaVenta),
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: IconButton(
                      onPressed: () => _confirmarEliminar(venta),
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleVenta(venta: venta),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
