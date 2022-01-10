/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/src/crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Benchmark Tests', () {
    test('benchmark_rsa', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      DateTime start = DateTime.now();
      print("RSA2048 Start: " + start.toIso8601String());
      for (int i = 0; i < 1000; i++) {
        Uint8List cipherText = rsaEncrypt(
            keyPair.publicKey, Uint8List.fromList(utf8.encode("hello world")));
      }
      DateTime stop = DateTime.now();
      Duration delta = stop.difference(start);
      double rate = 1000000 / (delta.inMicroseconds / 1000);
      print("RSA2048 Done: " + stop.toIso8601String());
      print("RSA2048 Delta (microseconds): " + delta.inMicroseconds.toString());
      print("RSA2048 Hash Rate: " + rate.round().toString());
    });

    test('benchmark_sha', () async {
      DateTime start = DateTime.now();
      print("SHA256 Start: " + start.toIso8601String());
      for (int i = 0; i < 1000; i++) {
        Uint8List hash = SHA256Digest()
            .process(Uint8List.fromList(utf8.encode("hello world")));
      }
      DateTime stop = DateTime.now();
      Duration delta = stop.difference(start);
      double rate = 1000000 / (delta.inMicroseconds / 1000);
      print("SHA256 Done: " + stop.toIso8601String());
      print("SHA256 Delta (microseconds): " + delta.inMicroseconds.toString());
      print("SHA256 Hash Rate: " + rate.round().toString());
    });

    test('benchmark_aes', () async {
      Uint8List key = await aesGenerate();
      var secureRandom = new FortunaRandom();
      var random = new Random.secure();
      final seeds = <int>[];
      for (int i = 0; i < 32; i++) seeds.add(random.nextInt(255));
      secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));
      Uint8List iv = secureRandom.nextBytes(16);

      DateTime start = DateTime.now();
      print("AES256 Start: " + start.toIso8601String());
      for (int i = 0; i < 1000; i++) {
        Uint8List cipherText =
            aesEncrypt(key, iv, Uint8List.fromList(utf8.encode("hello world")));
      }
      DateTime stop = DateTime.now();
      Duration delta = stop.difference(start);
      double rate = 1000000 / (delta.inMicroseconds / 1000);
      print("AES256 Done: " + stop.toIso8601String());
      print("AES256 Delta (microseconds): " + delta.inMicroseconds.toString());
      print("AES256 Hash Rate: " + rate.round().toString());
    });

    test('benchmark_ecdsa', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      DateTime start = DateTime.now();
      print("ECDSA Start: " + start.toIso8601String());
      for (int i = 0; i < 1000; i++) {
        Uint8List signature = ecdsaSign(
            keyPair.privateKey, Uint8List.fromList(utf8.encode("hello world")));
      }
      DateTime stop = DateTime.now();
      Duration delta = stop.difference(start);
      double rate = 1000000 / (delta.inMicroseconds / 1000);
      print("ECDSA Done: " + stop.toIso8601String());
      print("ECDSA Delta (microseconds): " + delta.inMicroseconds.toString());
      print("ECDSA Hash Rate: " + rate.round().toString());
    });
  });
}
