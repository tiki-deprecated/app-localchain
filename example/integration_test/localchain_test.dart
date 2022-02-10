/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/localchain.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localchain Tests', () {
    test('open_success', () async {
      await Localchain().open(Uuid().v4());
    });

    test('append_success', () async {
      Localchain localchain = await Localchain().open(Uuid().v4());
      Uint8List contents =
          Localchain.codec.encode(BlockContentsJson(json: '"hello":"world'));
      Block block = await localchain.append(contents);
      expect(block.created != null, true);
      expect(block.previousHash != null, true);
      expect(block.contents, contents);
    });

    test('get_success', () async {
      Localchain localchain = await Localchain().open(Uuid().v4());
      Uint8List contents =
          Localchain.codec.encode(BlockContentsJson(json: '"hello":"world'));
      for (int i = 0; i < 200; i++) await localchain.append(contents);
      List<Block> blocks = await localchain.get(onPage: (page) {
        expect(page.length > 0, true);
      });
      expect(blocks.length, 201);
    });

    test('validate_success', () async {
      Localchain localchain = await Localchain().open(Uuid().v4());
      Uint8List contents =
          Localchain.codec.encode(BlockContentsJson(json: '"hello":"world'));
      for (int i = 0; i < 200; i++) await localchain.append(contents);
      bool isValid = await localchain.validate();
      expect(isValid, true);
    });
  });
}
