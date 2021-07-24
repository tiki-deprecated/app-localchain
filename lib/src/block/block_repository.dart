/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db_page.dart';
import 'block_model.dart';

class BlockRepository {
  static const String _table = 'block';
  final log = Logger('BlockRepository');
  final Database database;

  BlockRepository(this.database);

  Future<BlockModel> insert(BlockModel block) async {
    int id = await database.insert(_table, block.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
    block.id = id;
    log.info('inserted: #' + id.toString());
    return block;
  }

  Future<BlockModel?> get(int id) async {
    List<Map<String, Object?>> rows = await database.query(_table,
        columns: ['id', 'contents', 'previous_hash', 'created_epoch'],
        where: 'id = ?',
        whereArgs: [id]);
    BlockModel block = BlockModel.fromMap(rows[0]);
    log.finest('got: ' + block.toString());
    return block;
  }

  Future<DbPage<BlockModel>> getPage(int pageNumber, int pageSize) async {
    List<Map<String, Object?>> rows = await database.query(_table,
        columns: ['id', 'contents', 'previous_hash', 'created_epoch'],
        where: 'id > ?',
        whereArgs: [pageNumber * pageSize],
        limit: pageSize,
        orderBy: 'id');
    int tableSize = await count() ?? 0;

    List<BlockModel> blocks =
        List.from(rows.map((row) => BlockModel.fromMap(row)));
    DbPage<BlockModel> page = DbPage(
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalElements: tableSize,
        totalPages: (tableSize / pageSize).ceil(),
        elements: blocks);

    log.finest('got Page: ' + page.toString());
    return page;
  }

  Future<int?> count() async {
    int? count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT (*) from $_table'));
    log.finest('count: ' + count.toString());
    return count;
  }

  Future<BlockModel> last() async {
    List<Map<String, Object?>> rows = await database.query(_table,
        columns: ['id', 'contents', 'previous_hash', 'created_epoch'],
        orderBy: 'id DESC',
        limit: 1);
    BlockModel block = BlockModel.fromMap(rows[0]);
    log.finest('last: ' + block.toString());
    return block;
  }
}
