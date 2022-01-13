/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

final _log = Logger('db_open');

Future<Database> open(String address,
        {int version = 2, String? password}) async =>
    openDatabase(await getDatabasesPath() + '/$address.db',
        version: version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onOpen: _onOpen,
        password: password,
        singleInstance: true);

Future<void> _onCreate(Database db, int version) {
  _log.info('create');
  return _executeScript(db, 'db_sql_create.sql');
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  _log.info('upgrade');
  if (oldVersion < 2) await _executeScript(db, 'db_sql_update_v2.sql');
}

void _onDowngrade(Database db, int oldVersion, int newVersion) =>
    throw UnimplementedError('downgrade not supported');

Future<void> _onOpen(Database db) async {
  _log.info('open');
  //this is where we should do the validation check
}

Future<void> _executeScript(Database db, String name) async {
  String script =
      await rootBundle.loadString('packages/localchain/src/db/sql/' + name);
  List<String> sqlList = script.split(";");
  for (String sqlString in sqlList) {
    String sql = sqlString.trim();
    if (sql.isNotEmpty) await db.execute(sql);
  }
}
