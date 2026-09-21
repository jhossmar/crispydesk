import 'package:flutter/material.dart';
import 'package:modelo_sqlite/estadisticas/estadisticas.dart';
import 'package:modelo_sqlite/features/auth/presentation/screens/registrar_usuario_screen.dart';
import 'package:modelo_sqlite/features/gastos/presentation/screens/gastos_screen.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/presentation/screens/producto_screen.dart';
import 'package:modelo_sqlite/features/ventas/domain/entities/venta.dart';
import 'package:modelo_sqlite/features/ventas/presentation/screens/cierre_caja_screen.dart';
import 'package:modelo_sqlite/features/ventas/presentation/screens/detalle_venta_screen.dart';
import 'package:modelo_sqlite/features/ventas/presentation/screens/listado_ventas_screen.dart';
import 'package:modelo_sqlite/features/ventas/presentation/screens/producto_cantidad_screen.dart';
import 'package:modelo_sqlite/features/ventas/presentation/screens/venta_screen.dart';
import 'package:modelo_sqlite/menu.dart';
import 'package:modelo_sqlite/reportes/reporte_fechas.dart';

/// Route name constants, so call sites use `Navigator.pushNamed(context,
/// AppRoutes.productos)` instead of hardcoded strings scattered everywhere.
///
/// There's no named route for the Menu screen: it's only ever reached
/// reactively through AuthGate (which owns the initial '/' route via
/// MaterialApp's `home`), never via an explicit push.
class AppRoutes {
  AppRoutes._();

  static const productos = '/productos';
  static const usuarios = '/usuarios';
  static const gastos = '/gastos';
  static const venta = '/venta';
  static const productoCantidad = '/venta/producto-cantidad';
  static const historialVentas = '/venta/historial';
  static const detalleVenta = '/venta/detalle';
  static const cierreCaja = '/cierre';
  static const estadisticas = '/estadisticas';
  static const reportes = '/reportes';
}

/// Fade + slide transition applied to every named route, instead of the
/// default MaterialPageRoute platform transition.
PageRouteBuilder<T> _rutaAnimada<T>(Widget child) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curva = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curva,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curva),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

Route<dynamic> generarRuta(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.productos:
      return _rutaAnimada(const ProductoScreen());
    case AppRoutes.usuarios:
      return _rutaAnimada(const RegistrarUsuarioScreen());
    case AppRoutes.gastos:
      return _rutaAnimada(const GastosScreen());
    case AppRoutes.venta:
      return _rutaAnimada(const VentaScreen());
    case AppRoutes.productoCantidad:
      final producto = settings.arguments as Producto;
      // Explicitly typed <int>: VentaScreen calls this with
      // Navigator.pushNamed<int>, which requires a Route<int?> - a
      // PageRouteBuilder<dynamic> fails that runtime type check.
      return _rutaAnimada<int>(ProductoCantidadScreen(producto: producto));
    case AppRoutes.historialVentas:
      return _rutaAnimada(const ListadoVentasScreen());
    case AppRoutes.detalleVenta:
      final venta = settings.arguments as Venta;
      return _rutaAnimada(DetalleVentaScreen(venta: venta));
    case AppRoutes.cierreCaja:
      return _rutaAnimada(const CierreCajaScreen());
    case AppRoutes.estadisticas:
      return _rutaAnimada(const Estadisticas());
    case AppRoutes.reportes:
      return _rutaAnimada(const ReporteFechas());
    default:
      return _rutaAnimada(const Menu());
  }
}
