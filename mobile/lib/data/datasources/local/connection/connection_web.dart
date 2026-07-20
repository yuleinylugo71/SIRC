import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor abrirConexion() {
  return WebDatabase('sirc_local_db', logStatements: false);
}
