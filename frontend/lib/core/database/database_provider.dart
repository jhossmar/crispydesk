import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/core/database/app_database.dart';

/// Shared across every feature's offline cache. Not autoDispose: the
/// underlying connection should live for the app's lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
