/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:localchain/src/crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:test/test.dart';

void main() {
  group('Crypto Package Unit Tests', () {
    test('rsaGenerate_success', () async {
      await rsaGenerate();
    });

    test('ecdsaGenerate_success', () async {
      await ecdsaGenerate();
    });

    test('rsaEncode_success', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      String publicKeyEncoded = rsaEncodePublicKey(keyPair.publicKey);
      String privateKeyEncoded = rsaEncodePrivateKey(keyPair.privateKey);
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('rsaDecodePublicKey_success', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      String publicKeyEncoded = rsaEncodePublicKey(keyPair.publicKey);
      RSAPublicKey publicKeyDecoded = rsaDecodePublicKey(publicKeyEncoded);
      expect(publicKeyDecoded.exponent, keyPair.publicKey.exponent);
      expect(publicKeyDecoded.modulus, keyPair.publicKey.modulus);
    });

    test('rsaDecodePrivateKey_success', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      String privateKeyEncoded = rsaEncodePrivateKey(keyPair.privateKey);
      RSAPrivateKey privateKeyDecoded = rsaDecodePrivateKey(privateKeyEncoded);

      expect(privateKeyDecoded.modulus, keyPair.privateKey.modulus);
      expect(privateKeyDecoded.exponent, keyPair.privateKey.exponent);
      expect(privateKeyDecoded.privateExponent,
          keyPair.privateKey.privateExponent);
      expect(
          privateKeyDecoded.publicExponent, keyPair.privateKey.publicExponent);
      expect(privateKeyDecoded.p, keyPair.privateKey.p);
      expect(privateKeyDecoded.q, keyPair.privateKey.q);
    });

    test('ecdsaEncode_success', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      String publicKeyEncoded = ecdsaEncodePublicKey(keyPair.publicKey);
      String privateKeyEncoded = ecdsaEncodePrivateKey(keyPair.privateKey);
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('ecdsaDecodePublicKey_success', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      String publicKeyEncoded = ecdsaEncodePublicKey(keyPair.publicKey);
      ECPublicKey publicKeyDecoded = ecdsaDecodePublicKey(publicKeyEncoded);
      expect(publicKeyDecoded.Q, keyPair.publicKey.Q);
      expect(publicKeyDecoded.Q?.x, keyPair.publicKey.Q?.x);
      expect(publicKeyDecoded.Q?.y, keyPair.publicKey.Q?.y);
      expect(publicKeyDecoded.Q?.curve, keyPair.publicKey.Q?.curve);
    });

    test('ecdsaDecodePrivateKey_success', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      String privateKeyEncoded = ecdsaEncodePrivateKey(keyPair.privateKey);
      ECPrivateKey privateKeyDecoded = ecdsaDecodePrivateKey(privateKeyEncoded);

      expect(privateKeyDecoded.d, keyPair.privateKey.d);
      expect(privateKeyDecoded.parameters?.curve,
          keyPair.privateKey.parameters?.curve);
    });
  });
}
