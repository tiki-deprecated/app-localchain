/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:localchain/localchain.dart';
import 'package:sqflite/sqlite_api.dart';

import 'cache_repository.dart';

class CacheService {
  final CacheRepository _cacheRepository;

  CacheService(Database database)
      : this._cacheRepository = CacheRepository(database);

  Future<void> drop() => _cacheRepository.drop();
  Future<CacheModel> insert(CacheModel cache) => _cacheRepository.insert(cache);

  Future<CacheModel?> get(int id) => _cacheRepository.get(id);
}
