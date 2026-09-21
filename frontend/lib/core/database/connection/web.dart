import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor connect() {
  return DatabaseConnection.delayed(
    Future(() async {
      final resultado = await WasmDatabase.open(
        databaseName: 'crispydesk_cache',
        sqlite3Uri: Uri.parse('sqlite3_drift.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return resultado.resolvedExecutor;
    }),
  );
}
