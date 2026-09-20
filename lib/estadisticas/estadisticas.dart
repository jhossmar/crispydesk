import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';

class Estadisticas extends StatefulWidget {
  const Estadisticas({super.key});

  @override
  State<Estadisticas> createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  final _dbHelper = DatabaseHelper();

  double _totalHoy = 0;
  int _cantidadHoy = 0;
  double _totalHistorico = 0;
  List<Map<String, dynamic>> _ranking = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final totalHoy = await _dbHelper.getTotalVentasHoy();
    final cantidadHoy = await _dbHelper.getCantidadVentasHoy();
    final totalHistorico = await _dbHelper.getTotalIngresosHistorico();
    final ranking = await _dbHelper.getRankingProductos();

    setState(() {
      _totalHoy = totalHoy;
      _cantidadHoy = cantidadHoy;
      _totalHistorico = totalHistorico;
      _ranking = ranking;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxUnidades = _ranking.isEmpty
        ? 1
        : (_ranking.first['totalUnidades'] as int);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ------- Estadística 1: resumen del día -------
            const Text(
              'Resumen de hoy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TarjetaEstadistica(
                    icono: Icons.point_of_sale,
                    titulo: 'Ventas hoy',
                    valor: '$_cantidadHoy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TarjetaEstadistica(
                    icono: Icons.attach_money,
                    titulo: 'Ingreso hoy',
                    valor: 'Bs. ${_totalHoy.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TarjetaEstadistica(
              icono: Icons.savings,
              titulo: 'Ingreso histórico total',
              valor: 'Bs. ${_totalHistorico.toStringAsFixed(2)}',
              ancho: double.infinity,
            ),

            const SizedBox(height: 28),

            // ------- Estadística 2: ranking de productos -------
            const Text(
              'Productos más vendidos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (_ranking.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Todavía no hay ventas registradas',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ..._ranking.map((fila) {
                final unidades = fila['totalUnidades'] as int;
                final ingreso = (fila['totalIngreso'] as num).toDouble();
                final proporcion = unidades / maxUnidades;

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
                              fila['nombreProducto'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '$unidades unid. · Bs. ${ingreso.toStringAsFixed(2)}',
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
