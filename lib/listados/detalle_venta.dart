import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';
import 'package:modelo_sqlite/modelos/modeloVenta.dart';
import 'package:modelo_sqlite/modelos/modeloDetalleVenta.dart';

class DetalleVenta extends StatefulWidget {
  final ModeloVenta venta;
  const DetalleVenta({super.key, required this.venta});

  @override
  State<DetalleVenta> createState() => _DetalleVentaState();
}

class _DetalleVentaState extends State<DetalleVenta> {
  final _dbHelper = DatabaseHelper();
  List<ModeloDetalleVenta> _detalles = [];

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
  }

  Future<void> _cargarDetalles() async {
    final detalles = await _dbHelper.getDetallesPorVenta(
      widget.venta.pkVenta!,
    );
    setState(() {
      _detalles = detalles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle venta #${widget.venta.pkVenta}')),
      body: Column(
        children: [
          Expanded(
            child: _detalles.isEmpty
                ? const Center(
                    child: Text(
                      'Sin líneas de detalle',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _detalles.length,
                    itemBuilder: (context, index) {
                      final d = _detalles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            d.nombreProducto,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${d.cantidad} x Bs. ${d.precioUnitario.toStringAsFixed(2)}',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            color: const Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total venta:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Bs. ${widget.venta.totalVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
