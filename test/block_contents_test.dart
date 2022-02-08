/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:localchain/localchain.dart';

void main() {
  setUp(() {});

  group('ContentsCodec Tests', () {
    test('decode_success', () async {
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

    test('schema_fail', () async {
      int randSize = 20;
      Random random = Random();
      Uint8List randomData = Uint8List(randSize);
      randomData[0] = 250;
      for (int i = 1; i < randSize; i++) randomData[i] = random.nextInt(256);
      expect(() => contentsCodec.decode(randomData),
          throwsA(isA<FormatException>()));
    });
  });

  group('BlockContentsDataBytea Tests', () {
    test('payload_success', () async {
      String val = 'Hello World';
      BlockContentsBytea contents =
          BlockContentsBytea(body: Uint8List.fromList(utf8.encode(val)));
      BlockContentsBytea decoded = BlockContentsBytea.payload(contents.payload);
      expect(decoded.body != null, true);
      expect(utf8.decode(decoded.body!), val);
      expect(contents, decoded);
    });
  });

  group('BlockContentsDataNft Tests', () {
    test('payload_success', () async {
      String fingerprint = 'fingerprint';
      String proof = 'proof';
      BlockContentsDataNft contents =
          BlockContentsDataNft(fingerprint: fingerprint, proof: proof);
      BlockContentsDataNft decoded =
          BlockContentsDataNft.payload(contents.payload);
      expect(fingerprint, decoded.fingerprint);
      expect(proof, decoded.proof);
      expect(contents, decoded);
    });

    test('payload_encode_fail', () async {
      String fingerprint = 'fingerprint';
      BlockContentsDataNft contents =
          BlockContentsDataNft(fingerprint: fingerprint);
      expect(() => contents.payload, throwsA(isA<FormatException>()));
    });

    test('payload_decode_fail', () async {
      int randSize = 20;
      Random random = Random();
      Uint8List randomData = Uint8List(randSize);
      randomData[0] = 250;
      for (int i = 1; i < randSize; i++) randomData[i] = random.nextInt(256);
      expect(() => BlockContentsDataNft.payload(randomData),
          throwsA(isA<FormatException>()));
    });
  });

  group('BlockContentsJson Tests', () {
    test('payload_success', () async {
      String json = '"hello":"world"';
      BlockContentsJson contents = BlockContentsJson(json: json);
      BlockContentsJson decoded = BlockContentsJson.payload(contents.payload);
      expect(json, decoded.json);
      expect(contents, decoded);
    });

    test('payload_encode_fail', () async {
      Map val = Map();
      val[0] = null;
      val[':'] = '\n';
      expect(() => BlockContentsJson.raw(val), throwsA(isA<FormatException>()));
    });

    test('payload_decode_fail', () async {
      int randSize = 20;
      Random random = Random();
      Uint8List randomData = Uint8List(randSize);
      randomData[0] = 250;
      for (int i = 1; i < randSize; i++) randomData[i] = random.nextInt(256);
      expect(() => BlockContentsJson.payload(randomData),
          throwsA(isA<FormatException>()));
    });
  });

  group('BlockContentsDataStart Tests', () {
    test('payload_success', () async {
      String start = 'START';
      BlockContentsStart contents = BlockContentsStart(start: start);
      BlockContentsStart decoded = BlockContentsStart.payload(contents.payload);
      expect(start, decoded.start);
      expect(contents, decoded);
    });

    test('payload_decode_fail', () async {
      int randSize = 20;
      Random random = Random();
      Uint8List randomData = Uint8List(randSize);
      for (int i = 0; i < randSize; i++) randomData[i] = random.nextInt(256);
      expect(() => BlockContentsStart.payload(randomData),
          throwsA(isA<FormatException>()));
    });
  });

  group('BlockContentsDataUriNft Tests', () {
    test('payload_success', () async {
      Uri uri = Uri.parse('https://mytiki.com');
      BlockContentsUriNft contents = BlockContentsUriNft(uri: uri);
      BlockContentsUriNft decoded =
          BlockContentsUriNft.payload(contents.payload);
      expect(uri, decoded.uri);
      expect(contents, decoded);
    });

    test('payload_encode_fail', () async {
      expect(() => BlockContentsUriNft.path('http;:/\nj//.co/m'),
          throwsA(isA<FormatException>()));
    });

    test('payload_decode_fail', () async {
      int randSize = 20;
      Random random = Random();
      Uint8List randomData = Uint8List(randSize);
      for (int i = 0; i < randSize; i++) randomData[i] = random.nextInt(256);
      expect(() => BlockContentsUriNft.payload(randomData),
          throwsA(isA<FormatException>()));
    });
  });
}
