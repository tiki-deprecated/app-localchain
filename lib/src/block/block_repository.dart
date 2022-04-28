/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'block_model.dart';

class BlockRepository {
  static const String _table = 'block';
  final _log = Logger('BlockRepository');

  final Database _database;

  BlockRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> insertAll(List<BlockModel> blocks, {Transaction? txn}) async {
    Batch batch = (txn ?? _database).batch();
    blocks.forEach((block) => batch.insert(_table, block.toMap()));
    await batch.commit(noResult: true);
  }

  Future<BlockModel> insert(BlockModel block, {Transaction? txn}) async {
    int id = await (txn ?? _database).insert(_table, block.toMap());
    block.id = id;
    _log.finest('inserted: #$id');
    return block;
  }

  Future<BlockModel?> findLast({Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
        columns: ['id', 'contents', 'previous_hash', 'created_epoch'],
        orderBy: 'id DESC',
        limit: 1);
    if (rows.isNotEmpty) {
      BlockModel block = BlockModel.fromMap(rows[0]);
      _log.finest('last: $block');
      return block;
    }
    return null;
  }

  Future<List<BlockModel>> findByPreviousHash(Uint8List previousHash,
      {Transaction? txn}) async {
    try {
      List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
          columns: [
            'id',
            'contents',
            'previous_hash',
            'created_epoch',
          ],
          where: '"previous_hash" = ?',
          whereArgs: [previousHash]);
      if (rows.isEmpty) return List.empty();
      List<BlockModel> blocks =
          rows.map((row) => BlockModel.fromMap(row)).toList();
      _log.finest('findByPreviousHash: ${blocks.length} block(s)');
      return blocks;
    } catch (error) {
      return List.empty();
    }
  }

  Future<List<BlockModel>> page(int number, int size,
      {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
        columns: ['id', 'contents', 'previous_hash', 'created_epoch'],
        where: '"id" > ?',
        whereArgs: [number * size],
        limit: size,
        orderBy: 'id');
    _log.finest('page: ${rows.length} records');
    return rows.isNotEmpty
        ? List.from(rows.map((row) => BlockModel.fromMap(row)))
        : List.empty();
  }

  Future<int> count({Transaction? txn}) async {
    int? count = Sqflite.firstIntValue(
        await (txn ?? _database).rawQuery('SELECT COUNT (*) FROM $_table'));
    _log.finest('count: $count');
    return count ?? 0;
  }
}
