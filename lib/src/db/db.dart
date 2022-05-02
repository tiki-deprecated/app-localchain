/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../block/block_service.dart';
import '../validate/validate_model.dart';
import '../validate/validate_service.dart';

final _log = Logger('db_open');

Future<Database> open(String address,
        {int version = 2, String? password, Duration? validate}) async =>
    openDatabase(await getDatabasesPath() + '/$address.db',
        version: version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onOpen: (db) => _onOpen(db, validate: validate),
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

Future<void> _onOpen(Database db, {Duration? validate}) async {
  _log.info('open');
  ValidateService validateService = ValidateService(db);
  ValidateModel? last = await validateService.last;
  if (last?.started == null ||
      DateTime.now()
              .difference(last!.started!)
              .compareTo(validate ?? Duration(days: 30)) >=
          0 ||
      last.didPass != true) {
    ValidateModel model = await validateService.start();
    try {
      await BlockService(db).validate();
      model.didPass = true;
      await validateService.pass(model);
    } catch (error) {
      model.didPass = false;
      await validateService.pass(model);
      throw error;
    }
  }
}

Future<void> _executeScript(Database db, String name) async {
  String script =
      await rootBundle.loadString('packages/tiki_localchain/src/db/sql/' + name);
  List<String> sqlList = script.split(";");
  for (String sqlString in sqlList) {
    String sql = sqlString.trim();
    if (sql.isNotEmpty) await db.execute(sql);
  }
}
