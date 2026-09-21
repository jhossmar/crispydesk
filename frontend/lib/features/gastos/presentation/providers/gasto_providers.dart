import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';
import 'package:modelo_sqlite/features/gastos/data/repositories/gasto_repository_impl.dart';
import 'package:modelo_sqlite/features/gastos/domain/entities/gasto.dart';
import 'package:modelo_sqlite/features/gastos/domain/repositories/gasto_repository.dart';

final gastoRepositoryProvider = Provider<GastoRepository>((ref) {
  return GastoRepositoryImpl(auth: ref.watch(authRepositoryProvider));
});

/// Keyed by year/month only (day is ignored by the backend) so switching
/// days within the same month reuses the cached result.
final mesGastosProvider = FutureProvider.autoDispose.family<MesGastos, DateTime>((ref, mes) {
  return ref.watch(gastoRepositoryProvider).obtenerMes(mes);
});
