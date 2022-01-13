/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:pointycastle/digests/sha256.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../db/db_model_page.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  final BlockRepository _repository;

  BlockService(Database database) : _repository = BlockRepository(database);

  Future<BlockModel> add(Uint8List contents) =>
      _repository.transaction<BlockModel>((txn) async {
        BlockModel last = await _repository.findLast(txn: txn);
        return _repository.insert(
            BlockModel(
                contents: contents,
                created: DateTime.now(),
                previousHash: _hash(last)),
            txn: txn);
      });

  Future<DbModelPage<BlockModel>> page(int number, int size) =>
      _repository.transaction<DbModelPage<BlockModel>>((txn) async {
        int count = await _repository.count(txn: txn);
        if (count == 0)
          return DbModelPage(
              pageSize: size,
              pageNumber: number,
              totalElements: 0,
              totalPages: 0,
              elements: List.empty());
        else {
          List<BlockModel> blocks = await _repository.page(number, size);
          return DbModelPage(
              pageSize: size,
              pageNumber: number,
              totalElements: count,
              totalPages: (count / size).ceil(),
              elements: blocks);
        }
      });

  Uint8List _hash(BlockModel block) {
    BytesBuilder bytesBuilder = BytesBuilder();
    bytesBuilder.add(block.contents!);
    bytesBuilder.add(block.previousHash!);
    bytesBuilder
        .add(_encodeBigInt(BigInt.from(block.created!.millisecondsSinceEpoch)));
    return SHA256Digest().process(bytesBuilder.toBytes());
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

  // From pointycastle/src/utils
  BigInt _decodeBigInt(List<int> bytes) {
    var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;

    BigInt result;

    if (bytes.length == 1) {
      result = BigInt.from(bytes[0]);
    } else {
      result = BigInt.zero;
      for (var i = 0; i < bytes.length; i++) {
        var item = bytes[bytes.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }
    return result != BigInt.zero
        ? negative
            ? result.toSigned(result.bitLength)
            : result
        : BigInt.zero;
  }
}
