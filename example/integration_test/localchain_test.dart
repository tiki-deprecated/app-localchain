/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/tiki_localchain.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localchain Tests', () {
    test('open_success', () async {
      await TikiLocalchain().open(Uuid().v4());
    });

    test('append_success', () async {
      TikiLocalchain localchain = await TikiLocalchain().open(Uuid().v4());
      Uint8List contents =
          TikiLocalchain.codec.encode(BlockContentsJson(json: '"hello":"world'));
      List<Block> blocks = await localchain.append([contents]);
      expect(blocks.length, 1);
      expect(blocks.elementAt(0).created != null, true);
      expect(blocks.elementAt(0).previousHash != null, true);
      expect(blocks.elementAt(0).contents, contents);
    });

    test('get_success', () async {
      TikiLocalchain localchain = await TikiLocalchain().open(Uuid().v4());
      List<Uint8List> contents = List.empty(growable: true);
      for (int i = 0; i < 200; i++)
        contents.add(
            TikiLocalchain.codec.encode(BlockContentsJson(json: '"hello":"world')));
      await localchain.append(contents);
      List<Block> blocks = await localchain.get(onPage: (page) {
        expect(page.length > 0, true);
      });
      expect(blocks.length, 201);
    });

    test('validate_success', () async {
      TikiLocalchain localchain = await TikiLocalchain().open(Uuid().v4());
      List<Uint8List> contents = List.empty(growable: true);
      for (int i = 0; i < 200; i++)
        contents.add(
            TikiLocalchain.codec.encode(BlockContentsJson(json: '"hello":"world')));
      await localchain.append(contents);
      bool isValid = await localchain.validate();
      expect(isValid, true);
    });
  });
}
