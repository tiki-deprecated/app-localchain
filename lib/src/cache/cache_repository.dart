/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import 'cache_model.dart';

class CacheRepository {
  static const String table = 'cache';
  final _log = Logger('CacheRepository');
  final Database _database;

  CacheRepository(this._database);

  Future<CacheModel> insert(CacheModel cache) async {
    await _database.insert(table, cache.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
    _log.info('insert: #' + cache.block!.id.toString());
    return cache;
  }

  Future<CacheModel?> get(int id) async {
    List<Map<String, Object?>> rows = await _database.rawQuery(
        "SELECT cache.contents AS cache_contents, "
        "cache.cached_epoch AS cache_cached_epoch, block.id AS block_id, "
        "block.contents AS block_contents, block.signature AS block_signature, "
        "block.previous_hash AS block_previous_hash, "
        "block.created_epoch AS block_created_epoch "
        "FROM cache "
        "INNER JOIN block ON block.id = cache.block_id "
        "WHERE block.id = ?",
        [id]);
    if (rows.isEmpty) return null;
    Map<String, Object?> blockMap = {
      'id': rows[0]['block_id'],
      'contents': rows[0]['block_contents'],
      'signature': rows[0]['block_signature'],
      'previous_hash': rows[0]['block_previous_hash'],
      'created_epoch': rows[0]['block_created_epoch']
    };

    Map<String, Object?> cacheMap = {
      'contents': rows[0]['cache_contents'],
      'cached_epoch': rows[0]['cache_cached_epoch'],
      'block': blockMap,
    };

    CacheModel cache = CacheModel.fromMap(cacheMap);
    _log.finest('got: ' + cache.toString());
    return cache;
  }

  Future<void> drop() async {
    _database.delete(table);
    _log.finest('dropped cache');
  }
}
