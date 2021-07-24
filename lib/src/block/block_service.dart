/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../db/db_config.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  final BlockRepository blockRepository;

  BlockService(DbConfig dbConfig)
      : this.blockRepository = BlockRepository(dbConfig.database);

  //TODO implement schema
  //TODO implement encryption
  //TODO implement hashing
  //TODO handle first insert
  Future<BlockModel> add(String plaintext) async {
    BlockModel last = await blockRepository.last();
    return blockRepository.insert(BlockModel(
        contents: plaintext,
        previousHash: last.contents,
        created: DateTime.now()));
  }
}
