/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:localchain/localchain.dart';

import '../db/db_config.dart';
import 'cache_repository.dart';

class CacheService {
  final CacheRepository _cacheRepository;

  CacheService(DbConfig dbConfig)
      : this._cacheRepository = CacheRepository(dbConfig.database);

  Future<void> drop() => _cacheRepository.drop();
  Future<CacheModel> insert(CacheModel cache) => _cacheRepository.insert(cache);

  Future<CacheModel?> get(int id) => _cacheRepository.get(id);
}
