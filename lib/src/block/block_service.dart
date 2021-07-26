/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sqflite/sqlite_api.dart';

import '../crypto/crypto.dart' as crypto;
import '../db/db_page.dart';
import '../key_store/key_store_service.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  final log = Logger('BlockService');
  final BlockRepository _blockRepository;
  final KeyStoreService _keyStoreService;

  BlockService(Database database, this._keyStoreService)
      : this._blockRepository = BlockRepository(database);

  //TODO handle first insert
  //TODO implement schema
  //TODO handle multiple sets of keys/users
  Future<BlockModel> add(Uint8List plainTextBytes) async {
    Uint8List cipherText =
        crypto.rsaEncrypt(_keyStoreService.dataKey!.publicKey, plainTextBytes);
    Uint8List signature =
        crypto.ecdsaSign(_keyStoreService.signKey!.privateKey, cipherText);

    BlockModel last = await _blockRepository.last();
    BlockModel inserted = await _blockRepository.insert(BlockModel(
        contents: cipherText,
        signature: signature,
        previousHash: _hash(last),
        created: DateTime.now()));
    return inserted;
  }

  Future<BlockModel> last() async => _blockRepository.last();

  Future<DbPage<BlockModel>> page(int pageNumber, int pageSize) async =>
      _blockRepository.page(pageNumber, pageSize);

  bool verifySignature(BlockModel block) {
    try {
      bool verified = crypto.ecdsaVerify(_keyStoreService.signKey!.publicKey,
          block.signature!, block.contents!);
      if (!verified) {
        log.info("Block #" + block.id.toString() + " invalid signature");
        return false;
      }
    } catch (_) {
      log.info("Block #" + block.id.toString() + " invalid signature");
      return false;
    }
    log.finest("Block #" + block.id.toString() + " valid signature");
    return true;
  }

  bool verifyContents(BlockModel block) {
    try {
      crypto.rsaDecrypt(_keyStoreService.dataKey!.privateKey, block.contents!);
      log.finest("Block #" + block.id.toString() + " valid contents");
      return true;
    } catch (_) {
      log.info("Block #" + block.id.toString() + " invalid contents");
      return false;
    }
  }

  Future<bool> verifyHash(BlockModel block) async {
    Uint8List hash = _hash(block);
    List<BlockModel> next = await _blockRepository.findByPreviousHash(hash);
    if (next.length == 0) {
      log.info("Block #" + block.id.toString() + " no next block");
      return false;
    } else if (next.length > 1) {
      log.info("Block #" + block.id.toString() + " multiple next blocks");
      return false;
    } else
      log.finest("Block #" + block.id.toString() + " valid next block");
    return true;
  }

  Uint8List _hash(BlockModel block) {
    BytesBuilder bytesBuilder = BytesBuilder();
    bytesBuilder.add(block.contents!);
    bytesBuilder.add(block.signature!);
    bytesBuilder.add(block.previousHash!);
    bytesBuilder.add(crypto
        .encodeBigInt(BigInt.from(block.created!.millisecondsSinceEpoch)));
    return SHA256Digest().process(bytesBuilder.toBytes());
  }
}
