import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/routes/app_routes.dart';
import 'package:modelo_sqlite/features/auth/domain/entities/usuario.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).value;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nombreCompleto ?? 'Broastería "El Sabor"',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          usuario?.rol == RolUsuario.administrador
                              ? 'Administrador'
                              : 'Cajera',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (usuario?.rol == RolUsuario.administrador)
              ListTile(
                leading: const Icon(
                  Icons.set_meal,
                  color: Colors.orangeAccent,
                ),
                title: const Text('Productos', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Platos de pollo y bebidas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.productos);
                },
              ),
            if (usuario?.rol == RolUsuario.administrador)
              ListTile(
                leading: const Icon(Icons.people, color: Colors.orangeAccent),
                title: const Text('Usuarios', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Crear cuentas de acceso'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.usuarios);
                },
              ),
            if (usuario?.rol == RolUsuario.administrador)
              ListTile(
                leading: const Icon(Icons.calculate, color: Colors.orangeAccent),
                title: const Text('Gastos', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Egresos y ganancia real'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.gastos);
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
                Navigator.pushNamed(context, AppRoutes.venta);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orangeAccent),
              title: const Text('Historial de ventas', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Listado de comandas registradas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.historialVentas);
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined, color: Colors.orangeAccent),
              title: const Text('Cierre de Caja', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Cierre y reconciliación de caja'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.cierreCaja);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.orangeAccent),
              title: const Text('Estadísticas', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Resumen del día y ranking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.estadisticas);
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
                Navigator.pushNamed(context, AppRoutes.reportes);
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
