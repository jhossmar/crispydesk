import 'package:flutter/material.dart';
import 'package:modelo_sqlite/cruds/producto.dart';
import 'package:modelo_sqlite/cruds/venta.dart';
import 'package:modelo_sqlite/listados/listado_ventas.dart';
import 'package:modelo_sqlite/estadisticas/estadisticas.dart';
import 'package:modelo_sqlite/reportes/reporte_fechas.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broastería - Sistema')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant,
              size: 90,
              color: Colors.orangeAccent.shade200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido/a',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gestión de venta de pollo y sodas',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade900, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orangeAccent.shade200,
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Broastería "El Sabor"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Panel administrativo',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.set_meal,
                color: Colors.orangeAccent,
              ),
              title: const Text('Productos', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Platos de pollo y bebidas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Producto()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.point_of_sale,
                color: Colors.orangeAccent,
              ),
              title: const Text('Registrar venta', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Nueva comanda / venta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Venta()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orangeAccent),
              title: const Text('Historial de ventas', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Listado de comandas registradas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListadoVentas()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.orangeAccent),
              title: const Text('Estadísticas', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Resumen del día y ranking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Estadisticas()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.orangeAccent,
              ),
              title: const Text('Reporte por fecha', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Diario o por rango de fechas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReporteFechas()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
