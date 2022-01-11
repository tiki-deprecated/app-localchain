/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

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
          previousHash: Uint8List.fromList([0, 1, 2, 3, 4]),
          created: DateTime.now()));
      expect(model.id != null, true);
    });

    test('findByPreviousHash_success', () async {
      Database database = await db.open('address');
      BlockRepository blockRepository = BlockRepository(database);
      await blockRepository.insert(BlockModel(
          contents: Uint8List.fromList([0, 1, 2, 3, 4]),
          previousHash: Uint8List.fromList([0, 1, 2, 3, 4]),
          created: DateTime.now()));
      List<BlockModel> models = await blockRepository
          .findByPreviousHash(Uint8List.fromList([0, 1, 2, 3, 4]));
      expect(models.length > 0, true);
    });
  });
}
