/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:localchain/src/block/contents/block_contents_data_nft.dart';
import 'package:localchain/src/block/contents/block_contents_uri_nft.dart';

void main() {
  setUp(() {});
  group('BlockContentsDataNft Tests', () {
    test('payload', () async {
      String fingerprint = 'fingerprint';
      String proof = 'proof';
      BlockContentsDataNft contents =
          BlockContentsDataNft(fingerprint: fingerprint, proof: proof);
      Uint8List payload = contents.payload;
      BlockContentsDataNft decoded = BlockContentsDataNft.payload(payload);
      expect(fingerprint, decoded.fingerprint);
      expect(proof, decoded.proof);
      expect(contents, decoded);
    });
  });

  group('BlockContentsUriNft Tests', () {
    test('payload', () async {
      Uri uri = Uri.parse('https://google.com');
      BlockContentsUriNft contents = BlockContentsUriNft(uri: uri);
      Uint8List payload = contents.payload;
      BlockContentsUriNft decoded = BlockContentsUriNft.payload(payload);
      expect(uri, decoded.uri);
      expect(contents, decoded);
    });
  });
}
