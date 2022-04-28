/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'validate_model.dart';

class ValidateRepository {
  static const String _table = 'validate';
  final _log = Logger('BlockRepository');

  final Database _database;

  ValidateRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<ValidateModel> insert(ValidateModel block, {Transaction? txn}) async {
    int id = await (txn ?? _database).insert(_table, block.toMap());
    block.id = id;
    _log.finest('inserted: #$id');
    return block;
  }

  Future<ValidateModel> update(ValidateModel block, {Transaction? txn}) async {
    await (txn ?? _database).update(_table, block.toMap(),
        where: '"id" = ?', whereArgs: [block.id]);
    _log.finest('updated : #${block.id}');
    return block;
  }

  Future<ValidateModel?> findLast({Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
        columns: ['id', 'started_epoch', 'pass_bool'],
        orderBy: 'id DESC',
        limit: 1);
    if (rows.isNotEmpty) {
      ValidateModel validate = ValidateModel.fromMap(rows[0]);
      _log.finest('last: $validate');
      return validate;
    }
    return null;
  }
}
