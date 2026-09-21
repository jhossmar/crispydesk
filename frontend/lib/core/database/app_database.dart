import 'package:drift/drift.dart';

import 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart'
    as impl;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CachedProductos, CachedVentas, CachedDetalleVentas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 3;

  // This is a disposable read-cache (see tables.dart) - it gets fully
  // repopulated on the next successful fetch, so schema changes just drop
  // and recreate everything rather than writing real column migrations.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );
}
