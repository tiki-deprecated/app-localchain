/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../db/db_model_page.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  final _log = Logger('BlockService');
  final BlockRepository _repository;

  BlockService(Database database) : _repository = BlockRepository(database);

  Future<BlockModel> add(Uint8List contents) =>
      _repository.transaction<BlockModel>((txn) async {
        BlockModel? last = await _repository.findLast(txn: txn);
        if (last == null) throw StateError("Failed to find last Block");
        return _repository.insert(
            BlockModel(
                contents: contents,
                created: DateTime.now(),
                previousHash: _hash(last)),
            txn: txn);
      });

  Future<DbModelPage<BlockModel>> page(int number, int size) => _repository
      .transaction<DbModelPage<BlockModel>>((txn) => _page(number, size, txn));

  Future<void> validate({int pageSize = 100}) =>
      _repository.transaction((txn) async {
        DbModelPage<BlockModel> page = await _page(0, pageSize, txn);
        await _validatePage(page, txn);
        while (
            page.pageNumber! < page.totalPages! - 1 && page.elements != null) {
          await _validatePage(page, txn);
          page = await _page(page.pageNumber! + 1, pageSize, txn);
        }
      });

  Future<void> _validatePage(
      DbModelPage<BlockModel> page, Transaction txn) async {
    for (BlockModel block in page.elements!) await _validateBlock(block, txn);
  }

  Future<void> _validateBlock(BlockModel block, Transaction txn) async {
    Uint8List hash = _hash(block);
    List<BlockModel> next =
        await _repository.findByPreviousHash(hash, txn: txn);
    if (next.length == 0) {
      BlockModel? last = await _repository.findLast(txn: txn);
      if (last == null) throw StateError("Failed to find last Block");
      Uint8List lastHash = _hash(last);
      if (!ListEquality().equals(hash, lastHash))
        throw StateError("Chain broken at Block ${block.id}, no child");
    } else if (next.length > 1)
      throw StateError("Chain illegally forks at Block ${block.id}");
    _log.finest("Block ${block.id} verified");
  }

  Future<DbModelPage<BlockModel>> _page(
      int number, int size, Transaction txn) async {
    int count = await _repository.count(txn: txn);
    if (count == 0)
      return DbModelPage(
          pageSize: size,
          pageNumber: number,
          totalElements: 0,
          totalPages: 0,
          elements: List.empty());
    else {
      List<BlockModel> blocks = await _repository.page(number, size, txn: txn);
      return DbModelPage(
          pageSize: size,
          pageNumber: number,
          totalElements: count,
          totalPages: (count / size).ceil(),
          elements: blocks);
    }
  }

  // From pointycastle/src/utils
  Uint8List _encodeBigInt(BigInt? number) {
    if (number == BigInt.zero) {
      return Uint8List.fromList([0]);
    }

    int needsPaddingByte;
    int rawSize;

    if (number! > BigInt.zero) {
      rawSize = (number.bitLength + 7) >> 3;
      needsPaddingByte = ((number >> (rawSize - 1) * 8) & BigInt.from(0x80)) ==
              BigInt.from(0x80)
          ? 1
          : 0;
    } else {
      needsPaddingByte = 0;
      rawSize = (number.bitLength + 8) >> 3;
    }

    final size = rawSize + needsPaddingByte;
    var result = Uint8List(size);
    for (var i = 0; i < rawSize; i++) {
      result[size - i - 1] = (number! & BigInt.from(0xff)).toInt();
      number = number >> 8;
    }
    return result;
  }

  Uint8List _hash(BlockModel block) {
    BytesBuilder bytesBuilder = BytesBuilder();
    bytesBuilder.add(block.contents!);
    bytesBuilder.add(block.previousHash!);
    bytesBuilder
        .add(_encodeBigInt(BigInt.from(block.created!.millisecondsSinceEpoch)));
    return SHA256Digest().process(bytesBuilder.toBytes());
  }
}
