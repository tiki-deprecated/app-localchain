/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:localchain/localchain.dart';

void main() {
  setUp(() {});
  group('BlockContentsDataNft Tests', () {
    test('payload', () async {
      String fingerprint = 'fingerprint';
      String proof = 'proof';
      BlockContentsDataNft contents =
          BlockContentsDataNft(fingerprint: fingerprint, proof: proof);
      Uint8List block = contentsCodec.encode(contents);
      BlockContentsDataNft decoded = contentsCodec.decode(block);
      expect(fingerprint, decoded.fingerprint);
      expect(proof, decoded.proof);
      expect(contents, decoded);
    });
  });
}
