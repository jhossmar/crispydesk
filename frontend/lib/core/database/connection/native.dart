import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor connect() {
  return LazyDatabase(() async {
    final directorio = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(directorio.path, 'crispydesk_cache.sqlite'));
    return NativeDatabase.createInBackground(archivo);
  });
}
