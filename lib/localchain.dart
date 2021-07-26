library localchain;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localchain/src/block/block_service.dart';
import 'package:localchain/src/cache/cache_model.dart';
import 'package:localchain/src/cache/cache_service.dart';
import 'package:logging/logging.dart';

import 'src/block/block_model.dart';
import 'src/crypto/crypto.dart' as crypto;
import 'src/db/db_config.dart';
import 'src/db/db_page.dart';
import 'src/key_store/key_store_exception.dart';
import 'src/key_store/key_store_service.dart';

export 'src/block/block_model.dart';
export 'src/cache/cache_model.dart';
export 'src/key_store/key_store_model.dart';

class Localchain {
  static const int _pageSize = 100;
  final log = Logger('Localchain');
  final DbConfig _dbConfig = DbConfig();
  final KeyStoreService keystore;
  late final CacheService _cacheService;
  late final BlockService _blockService;

  Localchain({FlutterSecureStorage? secureStorage})
      : this.keystore = KeyStoreService(secureStorage: secureStorage);

  //pass callback to verify complete
  Future<void> open() async {
    await _dbConfig.init(keystore);
    this._cacheService = CacheService(_dbConfig.database);
    this._blockService = BlockService(_dbConfig.database, keystore);
    await verify();
  }

  Future<BlockModel> add(String plaintext) async {
    _keyGuard();
    Uint8List plainTextBytes = Uint8List.fromList(utf8.encode(plaintext));
    BlockModel block = await _blockService.add(plainTextBytes);
    await _cacheService.insert(CacheModel(
        contents: plainTextBytes, cached: DateTime.now(), block: block));
    return block;
  }

  Future<CacheModel?> get(int id) => _cacheService.get(id);

  Future<bool> verify() async {
    _keyGuard();
    BlockModel last = await _blockService.last();
    DbPage<BlockModel> page = await _blockService.page(0, _pageSize);
    while (page.pageNumber! < page.totalPages!) {
      for (BlockModel block in page.elements) {
        if (!_blockService.verifySignature(block)) return false;
        if (!_blockService.verifyContents(block)) return false;
        if (block.id != last.id && !await _blockService.verifyHash(block))
          return false;
        log.finest("Block #" + block.id.toString() + " passed verification");
      }
      page = await _blockService.page(page.pageNumber! + 1, _pageSize);
    }
    log.info("Chain passed verification");
    return true;
  }

  Future<bool> refresh() async {
    _keyGuard();
    await _cacheService.drop();
    BlockModel last = await _blockService.last();
    DbPage<BlockModel> page = await _blockService.page(0, _pageSize);
    while (page.pageNumber! < page.totalPages!) {
      for (BlockModel block in page.elements) {
        if (!_blockService.verifySignature(block)) return false;
        if (last.id != block.id && !await _blockService.verifyHash(block))
          return false;
        try {
          await _cacheService.insert(CacheModel(
              contents: crypto.rsaDecrypt(
                  keystore.dataKey!.privateKey, block.contents!),
              cached: DateTime.now(),
              block: block));
        } catch (_) {
          log.info("Failed to cache Block #" + block.id.toString());
          return false;
        }
        log.finest("Block #" + block.id.toString() + " cached");
      }
      page = await _blockService.page(page.pageNumber! + 1, _pageSize);
    }
    log.info("Cache refresh success");
    return true;
  }

  void _keyGuard() {
    if (keystore.signKey == null || keystore.dataKey == null)
      throw KeyStoreException("Missing required keys",
          address: keystore.active?.address);
  }
}
