/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:localchain/src/db/db_model_page.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'src/block/block.dart';
import 'src/block/block_model.dart';
import 'src/block/block_service.dart';
import 'src/block/contents/block_contents_codec.dart';
import 'src/db/db.dart' as db;

export 'src/block/block.dart';
export 'src/block/contents/block_contents.dart';
export 'src/block/contents/block_contents_bytea.dart';
export 'src/block/contents/block_contents_codec.dart';
export 'src/block/contents/block_contents_data_nft.dart';
export 'src/block/contents/block_contents_json.dart';
export 'src/block/contents/block_contents_schema.dart';
export 'src/block/contents/block_contents_start.dart';
export 'src/block/contents/block_contents_uri_nft.dart';

class Localchain {
  final Logger _log = Logger('localchain');
  late final BlockService _blockService;

  Future<Localchain> open(String address,
      {String? password, Duration? validate}) async {
    Database database = await db.open(address,
        password: password, validate: validate ?? Duration(days: 30));
    _blockService = BlockService(database);
    return this;
  }

  static BlockContentsCodec get codec => contentsCodec;

  Future<Block> append(Uint8List contents) async {
    BlockModel model = await _blockService.add(contents);
    return Block(
        contents: model.contents,
        previousHash: model.previousHash,
        created: model.created);
  }

  Future<bool> validate({int pageSize = 100}) async {
    try {
      await _blockService.validate(pageSize: pageSize);
      return true;
    } catch (error) {
      _log.severe('failed to validate localchain', error);
      return false;
    }
  }

  Future<List<Block>> get(
      {int pageSize = 100, void Function(List<Block>)? onPage}) async {
    int pageNum = 0;
    int totalPages = 1;
    List<Block> chain = List.empty(growable: true);
    while (pageNum < totalPages) {
      DbModelPage<BlockModel> page =
          await _blockService.page(pageNum, pageSize);
      if (page.elements != null) {
        List<Block> blocks = page.elements!
            .map((block) => Block(
                contents: block.contents,
                previousHash: block.previousHash,
                created: block.created))
            .toList();
        if (onPage != null) onPage(blocks);
        chain.addAll(blocks);
      }
      pageNum++;
      totalPages = page.totalPages ?? pageNum;
    }
    return chain;
  }
}
