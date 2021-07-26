/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

import '../db/db_page.dart';
import 'block_model.dart';

class BlockRepository {
  static const String table = 'block';
  final _log = Logger('BlockRepository');
  final Database _database;

  BlockRepository(this._database);

  Future<BlockModel> insert(BlockModel block) async {
    int id = await _database.insert(table, block.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
    block.id = id;
    _log.info('inserted: #' + id.toString());
    return block;
  }

  Future<BlockModel?> findById(int id) async {
    List<Map<String, Object?>> rows = await _database.query(table,
        columns: [
          'id',
          'contents',
          'signature',
          'previous_hash',
          'created_epoch'
        ],
        where: 'id = ?',
        whereArgs: [id]);
    if (rows.isEmpty) return null;
    BlockModel block = BlockModel.fromMap(rows[0]);
    _log.finest('findById: ' + block.toString());
    return block;
  }

  Future<List<BlockModel>> findByPreviousHash(Uint8List previousHash) async {
    try {
      List<Map<String, Object?>> rows = await _database.rawQuery(
          "SELECT id, contents, signature, previous_hash, created_epoch "
                  "FROM block WHERE previous_hash = X'" +
              hex(previousHash) +
              "'");
      if (rows.isEmpty) return List.empty();
      List<BlockModel> blocks =
          rows.map((row) => BlockModel.fromMap(row)).toList();
      _log.finest(
          'findByPreviousHash: ' + blocks.length.toString() + " block(s)");
      return blocks;
    } catch (_) {
      return List.empty();
    }
  }

  Future<DbPage<BlockModel>> page(int pageNumber, int pageSize) async {
    List<Map<String, Object?>> rows = await _database.query(table,
        columns: [
          'id',
          'contents',
          'signature',
          'previous_hash',
          'created_epoch'
        ],
        where: 'id > ?',
        whereArgs: [pageNumber * pageSize],
        limit: pageSize,
        orderBy: 'id');
    int tableSize = await count() ?? 0;

    List<BlockModel> blocks = rows.isNotEmpty
        ? List.from(rows.map((row) => BlockModel.fromMap(row)))
        : List.empty();
    DbPage<BlockModel> page = DbPage(
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalElements: tableSize,
        totalPages: (tableSize / pageSize).ceil(),
        elements: blocks);

    _log.finest('page: ' + page.toString());
    return page;
  }

  Future<int?> count() async {
    int? count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT (*) from $table'));
    _log.finest('count: ' + count.toString());
    return count;
  }

  Future<BlockModel> last() async {
    List<Map<String, Object?>> rows = await _database.query(table,
        columns: [
          'id',
          'contents',
          'signature',
          'previous_hash',
          'created_epoch'
        ],
        orderBy: 'id DESC',
        limit: 1);
    BlockModel block = BlockModel.fromMap(rows[0]);
    _log.finest('last: ' + block.toString());
    return block;
  }
}
