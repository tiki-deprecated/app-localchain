/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/src/block/block_model.dart';
import 'package:localchain/src/block/block_repository.dart';
import 'package:localchain/src/db/db.dart' as db;
import 'package:sqflite_sqlcipher/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('BlockRepository Tests', () {
    test('insert_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      BlockModel model = await blockRepository.insert(BlockModel(
          contents: Uint8List.fromList([0, 1, 2, 3, 4]),
          previousHash: Uint8List.fromList([0]),
          created: DateTime.now()));
      expect(model.id != null, true);
    });

    test('findByPreviousHash_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      int prev = Random().nextInt(255);
      await blockRepository.insert(BlockModel(
          contents: Uint8List.fromList([0, 1, 2, 3, 4]),
          previousHash: Uint8List.fromList([prev]),
          created: DateTime.now()));
      List<BlockModel> models =
          await blockRepository.findByPreviousHash(Uint8List.fromList([prev]));
      expect(1, models.length);
    });

    test('count_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      int count = await blockRepository.count();
      expect(count > 1, true);
    });

    test('page_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      int count = await blockRepository.count();
      List<BlockModel> page = await blockRepository.page(0, 100);
      expect(page.length, count);
    });

    test('findLast_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      List<BlockModel> page = await blockRepository.page(0, 100);
      BlockModel? last = await blockRepository.findLast();
      expect(last, page.last);
    });
  });
}
