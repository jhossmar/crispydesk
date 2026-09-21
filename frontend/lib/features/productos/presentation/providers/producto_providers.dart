import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/database/database_provider.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';
import 'package:modelo_sqlite/features/productos/data/repositories/producto_repository_impl.dart';
import 'package:modelo_sqlite/features/productos/domain/repositories/producto_repository.dart';

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepositoryImpl(
    auth: ref.watch(authRepositoryProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

/// Call `ref.invalidate(listaProductosProvider)` after any mutation to refresh.
final listaProductosProvider = FutureProvider.autoDispose<ResultadoProductos>((ref) {
  return ref.watch(productoRepositoryProvider).obtenerProductos();
});
