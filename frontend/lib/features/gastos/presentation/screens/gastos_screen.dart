import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/gastos/domain/entities/gasto.dart';
import 'package:modelo_sqlite/features/gastos/domain/repositories/gasto_repository.dart';
import 'package:modelo_sqlite/features/gastos/presentation/providers/gasto_providers.dart';

class GastosScreen extends ConsumerStatefulWidget {
  const GastosScreen({super.key});

  @override
  ConsumerState<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends ConsumerState<GastosScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _fecha = DateTime.now();
  String _categoriaSeleccionada = categoriasGasto.first;
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _guardando = false;

  DateTime _mesSeleccionado = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get _mesNormalizado => DateTime(_mesSeleccionado.year, _mesSeleccionado.month);

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  String _fmtFecha(DateTime d) => '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year}';

  Future<void> _elegirFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (seleccionada != null) setState(() => _fecha = seleccionada);
  }

  Future<void> _elegirMes() async {
    final seleccionado = await showDatePicker(
      context: context,
      initialDate: _mesSeleccionado,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (seleccionado != null) {
      setState(() => _mesSeleccionado = DateTime(seleccionado.year, seleccionado.month));
    }
  }

  Future<void> _registrarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await ref
          .read(gastoRepositoryProvider)
          .registrarGasto(
            fecha: _fecha,
            categoria: _categoriaSeleccionada,
            monto: double.parse(_montoController.text),
            descripcion: _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
          );
      _montoController.clear();
      _descripcionController.clear();
      setState(() {
        _mesSeleccionado = DateTime(_fecha.year, _fecha.month);
      });
      ref.invalidate(mesGastosProvider(_mesNormalizado));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto registrado correctamente')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo registrar el gasto: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminarGasto(Gasto gasto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text(
          '¿Eliminar "${gasto.categoria}" de Bs. ${gasto.monto.toStringAsFixed(2)} '
          'del ${_fmtFecha(gasto.fecha)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmo'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await ref.read(gastoRepositoryProvider).eliminarGasto(gasto.id);
      ref.invalidate(mesGastosProvider(_mesNormalizado));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar el gasto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mesAsync = ref.watch(mesGastosProvider(_mesNormalizado));

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Registrar gasto',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _elegirFecha,
                        child: Text('Fecha: ${_fmtFecha(_fecha)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _categoriaSeleccionada,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: categoriasGasto
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _categoriaSeleccionada = value ?? categoriasGasto.first);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _montoController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Monto Bs.'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Ingresa un monto válido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descripcionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _guardando ? null : _registrarGasto,
                  child: Text(_guardando ? 'Guardando...' : 'Guardar gasto'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen del mes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              OutlinedButton(
                onPressed: _elegirMes,
                child: Text('${_dosDigitos(_mesSeleccionado.month)}/${_mesSeleccionado.year}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          mesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'No se pudo cargar el resumen: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
            data: (mesGastos) {
              final resumen = mesGastos.resumen;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total ventas: Bs. ${resumen.totalVentasMes.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Total gastos: Bs. ${resumen.totalGastos.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ganancia real: Bs. ${resumen.gananciaReal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: resumen.gananciaReal >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (resumen.porCategoria.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: resumen.porCategoria
                          .map(
                            (c) => Text(
                              '${c.categoria}: Bs. ${c.monto.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Gastos registrados',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (mesGastos.gastos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No hay gastos registrados este mes',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  else
                    ...mesGastos.gastos.map((gasto) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            '${gasto.categoria} · Bs. ${gasto.monto.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${_fmtFecha(gasto.fecha)}'
                            '${gasto.descripcion != null ? ' · ${gasto.descripcion}' : ''}\n'
                            'Registrado por: ${gasto.registradoPorNombre}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          isThreeLine: gasto.descripcion != null,
                          trailing: IconButton(
                            onPressed: () => _eliminarGasto(gasto),
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
