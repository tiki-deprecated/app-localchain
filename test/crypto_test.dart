/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

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

    test('rsaEncrypt_success', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      Uint8List cipherText = rsaEncrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode("hello world")));
      String cipherTextString = String.fromCharCodes(cipherText);

      expect(cipherText.isNotEmpty, true);
      expect(cipherTextString.isNotEmpty, true);
    });

    test('rsaDecrypt_success', () async {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          await rsaGenerate();
      String plainText = "hello world";
      Uint8List cipherText = rsaEncrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode(plainText)));
      String result = utf8.decode(rsaDecrypt(keyPair.privateKey, cipherText));
      expect(result, plainText);
    });

    test('ecdsaSign_success', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      String message = "hello world";
      Uint8List signature = ecdsaSign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('ecdsaVerify_success', () async {
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair =
          await ecdsaGenerate();
      String message = "hello world";
      Uint8List signature = ecdsaSign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = ecdsaVerify(keyPair.publicKey, signature,
          Uint8List.fromList(utf8.encode(message)));
      expect(verify, true);
    });
  });
}
