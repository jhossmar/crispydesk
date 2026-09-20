import 'package:flutter/material.dart';
import 'package:modelo_sqlite/helpers/ab_helper.dart';
import 'package:modelo_sqlite/modelos/modeloVenta.dart';
import 'package:modelo_sqlite/listados/detalle_venta.dart';

/// Reporte de ventas administrable por día o por rango de fechas.
/// Muestra: resumen (cantidad + ingreso), desglose día por día,
/// ranking de productos del rango y el listado de ventas incluidas.
class ReporteFechas extends StatefulWidget {
  const ReporteFechas({super.key});

  @override
  State<ReporteFechas> createState() => _ReporteFechasState();
}

class _ReporteFechasState extends State<ReporteFechas> {
  final _dbHelper = DatabaseHelper();

  DateTime _desde = DateTime.now();
  DateTime _hasta = DateTime.now();

  bool _cargando = true;
  int _cantidadVentas = 0;
  double _totalIngreso = 0;
  List<Map<String, dynamic>> _resumenDiario = [];
  List<Map<String, dynamic>> _ranking = [];
  List<ModeloVenta> _ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    setState(() => _cargando = true);

    final resumen = await _dbHelper.getResumenPorRango(_desde, _hasta);
    final diario = await _dbHelper.getResumenDiarioPorRango(_desde, _hasta);
    final ranking = await _dbHelper.getRankingProductosPorRango(
      _desde,
      _hasta,
    );
    final ventas = await _dbHelper.getVentasPorRango(_desde, _hasta);

    if (!mounted) return;
    setState(() {
      _cantidadVentas = resumen['cantidad'] as int;
      _totalIngreso = resumen['total'] as double;
      _resumenDiario = diario;
      _ranking = ranking;
      _ventas = ventas;
      _cargando = false;
    });
  }

  void _fijarRango(DateTime desde, DateTime hasta) {
    setState(() {
      _desde = desde;
      _hasta = hasta;
    });
    _cargarReporte();
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
    _cargarReporte();
  }

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  String _fmtFecha(DateTime d) =>
      '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year}';

  String _fmtFechaHora(String iso) {
    final d = DateTime.parse(iso);
    return '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year} '
        '${_dosDigitos(d.hour)}:${_dosDigitos(d.minute)}';
  }

  // 'dia' viene como 'YYYY-MM-DD' desde el GROUP BY en SQL
  String _fmtDiaCorto(String isoDia) {
    final partes = isoDia.split('-');
    return '${partes[2]}/${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final promedio = _cantidadVentas == 0
        ? 0.0
        : _totalIngreso / _cantidadVentas;
    final maxDiario = _resumenDiario.isEmpty
        ? 1.0
        : _resumenDiario
              .map((e) => (e['total'] as num).toDouble())
              .fold<double>(1.0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte por fecha')),
      body: RefreshIndicator(
        onRefresh: _cargarReporte,
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
                ActionChip(
                  label: const Text('Últimos 7 días'),
                  onPressed: _ultimos7Dias,
                ),
                ActionChip(label: const Text('Este mes'), onPressed: _esteMes),
              ],
            ),
            const SizedBox(height: 20),

            if (_cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _tarjeta(
                      'Ventas',
                      '$_cantidadVentas',
                      Icons.point_of_sale,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tarjeta(
                      'Ingreso',
                      'Bs. ${_totalIngreso.toStringAsFixed(2)}',
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
              const Text(
                'Desglose por día',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_resumenDiario.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sin ventas en este rango',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ..._resumenDiario.map((fila) {
                  final dia = fila['dia'] as String;
                  final cantidad = fila['cantidad'] as int;
                  final total = (fila['total'] as num).toDouble();
                  final proporcion = (total / maxDiario).clamp(0.02, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmtDiaCorto(dia),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '$cantidad ventas · Bs. ${total.toStringAsFixed(2)}',
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
              const Text(
                'Productos vendidos en el rango',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_ranking.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sin ventas en este rango',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ..._ranking.map((fila) {
                  final unidades = fila['totalUnidades'] as int;
                  final ingreso = (fila['totalIngreso'] as num).toDouble();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        fila['nombreProducto'] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        '$unidades unid. · Bs. ${ingreso.toStringAsFixed(2)}',
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
                    '${_ventas.length}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_ventas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sin ventas en este rango',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ..._ventas.map((venta) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orangeAccent.shade200,
                        child: Text(
                          '#${venta.pkVenta}',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleVenta(venta: venta),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(
    String titulo,
    String valor,
    IconData icono, {
    double? ancho,
  }) {
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
          Text(
            titulo,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
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
