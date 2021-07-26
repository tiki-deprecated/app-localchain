/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:pointycastle/digests/sha256.dart';

import '../cache/cache_model.dart';
import '../cache/cache_service.dart';
import '../crypto/crypto.dart' as crypto;
import '../db/db_config.dart';
import '../db/db_page.dart';
import '../key_store/key_store_exception.dart';
import '../key_store/key_store_service.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int _pageSize = 100;
  final log = Logger('BlockRepository');
  final BlockRepository _blockRepository;
  final KeyStoreService _keyStoreService;
  final CacheService _cacheService;

  BlockService(DbConfig dbConfig, this._keyStoreService, this._cacheService)
      : this._blockRepository = BlockRepository(dbConfig.database);

  //TODO handle first insert
  //TODO implement schema
  //TODO implement chain validation
  //TODO handle multiple sets of keys/users
  //-- on open first validate chain (which will require correct public sign key)
  //-- confirm valid private sign key by re-signing and confirming the last message
  //-- then load into cache (which will require correct private data key)
  Future<BlockModel> add(String plaintext) async {
    if (_keyStoreService.dataKey == null || _keyStoreService.signKey == null)
      throw KeyStoreException("Private keys required to write to chain");

    Uint8List plainTextBytes = Uint8List.fromList(utf8.encode(plaintext));

    DateTime now = DateTime.now();
    Uint8List cipherText =
        crypto.rsaEncrypt(_keyStoreService.dataKey!.publicKey, plainTextBytes);
    Uint8List signature =
        crypto.ecdsaSign(_keyStoreService.signKey!.privateKey, cipherText);

    BlockModel last = await _blockRepository.last();
    BlockModel inserted = await _blockRepository.insert(BlockModel(
        contents: cipherText,
        signature: signature,
        previousHash: _hash(last),
        created: now));
    await _cacheService.insert(
        CacheModel(contents: plainTextBytes, cached: now, block: inserted));

    return inserted;
  }

  Future<bool> verifyChain() async {
    if (_keyStoreService.signKey == null || _keyStoreService.dataKey == null)
      throw KeyStoreException("Missing required keys",
          address: _keyStoreService.active?.address);

    BlockModel last = await _blockRepository.last();
    DbPage<BlockModel> page = await _blockRepository.page(0, _pageSize);
    while (page.pageNumber! < page.totalPages!) {
      for (BlockModel block in page.elements) {
        if (!await verifyBlock(block, isLast: block.id == last.id)) {
          log.info("Chain failed verification");
          return false;
        }
      }
      page = await _blockRepository.page(page.pageNumber! + 1, _pageSize);
    }
    log.info("Chain passed verification");
    return true;
  }

  Future<bool> verifyBlock(BlockModel block, {bool isLast = false}) async {
    if (!_verifySignature(block)) {
      log.info("Block failed signature verification");
      return false;
    }
    if (!_verifyContents(block)) {
      log.info("Block failed content verification");
      return false;
    }
    if (!isLast && !await _verifyHash(block)) {
      log.info("Block failed hash verification");
      return false;
    }
    log.finest("Block #" + block.id.toString() + " passed verification");
    return true;
  }

  Future<bool> refreshCache() async {
    if (_keyStoreService.signKey == null || _keyStoreService.dataKey == null)
      throw KeyStoreException("Missing required keys",
          address: _keyStoreService.active?.address);

    await _cacheService.drop();
    BlockModel last = await _blockRepository.last();
    DbPage<BlockModel> page = await _blockRepository.page(0, _pageSize);
    while (page.pageNumber! < page.totalPages!) {
      for (BlockModel block in page.elements) {
        if (!_verifySignature(block)) {
          log.info("Block failed signature verification");
          return false;
        }
        if (last.id != block.id && !await _verifyHash(block)) {
          log.info("Block failed hash verification");
          return false;
        }
        try {
          await _cacheService.insert(CacheModel(
              contents: crypto.rsaDecrypt(
                  _keyStoreService.dataKey!.privateKey, block.contents!),
              cached: DateTime.now(),
              block: block));
        } catch (_) {
          log.info("Block failed contents decrypt");
          return false;
        }
      }
      page = await _blockRepository.page(page.pageNumber! + 1, _pageSize);
    }
    log.info("Cache refresh success");
    return true;
  }

  bool _verifySignature(BlockModel block) {
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

  bool _verifyContents(BlockModel block) {
    try {
      crypto.rsaDecrypt(_keyStoreService.dataKey!.privateKey, block.contents!);
      log.finest("Block #" + block.id.toString() + " valid contents");
      return true;
    } catch (_) {
      log.info("Block #" + block.id.toString() + " invalid contents");
      return false;
    }
  }

  Future<bool> _verifyHash(BlockModel block) async {
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
