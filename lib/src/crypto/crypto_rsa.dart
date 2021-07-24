/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

Future<CryptoKeyPair> rsaGenerate() async {
  return await compute(_rsaGenerate, "").then((keyPair) => keyPair);
}

CryptoKeyPair _rsaGenerate(_) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
  return CryptoKeyPair(
      public: _rsaEncodePublicKey(keyPair.publicKey as RSAPublicKey),
      private: _rsaEncodePrivateKey(keyPair.privateKey as RSAPrivateKey));
}

String _rsaEncodePublicKey(RSAPublicKey publicKey) {
  ASN1Sequence sequence = ASN1Sequence();
  ASN1Sequence algorithm = ASN1Sequence();
  ASN1Object paramsAsn1Obj =
      ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithm
      .add(ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'));
  algorithm.add(paramsAsn1Obj);

  ASN1Sequence publicKeySequence = ASN1Sequence();
  ASN1Integer modulus = ASN1Integer(publicKey.modulus);
  ASN1Integer exponent = ASN1Integer(publicKey.exponent);
  publicKeySequence.add(modulus);
  publicKeySequence.add(exponent);
  publicKeySequence.encode();
  ASN1BitString publicKeyBitString = ASN1BitString();
  publicKeyBitString.stringValues = publicKeySequence.encodedBytes;

  sequence.add(algorithm);
  sequence.add(publicKeyBitString);
  sequence.encode();
  return base64.encode(sequence.encodedBytes!);
}

String _rsaEncodePrivateKey(RSAPrivateKey privateKey) {
  ASN1Sequence sequence = ASN1Sequence();
  ASN1Integer version = ASN1Integer(BigInt.from(0));
  ASN1Sequence algorithm = ASN1Sequence();
  ASN1Object paramsAsn1Obj =
      ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithm
      .add(ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'));
  algorithm.add(paramsAsn1Obj);

  ASN1Sequence privateKeySequence = ASN1Sequence();
  ASN1Integer privateKeyVersion = ASN1Integer(BigInt.from(1));
  ASN1Integer modulus = ASN1Integer(privateKey.modulus);
  ASN1Integer publicExponent = ASN1Integer(privateKey.publicExponent);
  ASN1Integer privateExponent = ASN1Integer(privateKey.privateExponent);
  ASN1Integer prime1 = ASN1Integer(privateKey.p);
  ASN1Integer prime2 = ASN1Integer(privateKey.q);
  ASN1Integer exponent1 = ASN1Integer(
      privateKey.privateExponent! % (privateKey.p! - BigInt.from(1)));
  ASN1Integer exponent2 = ASN1Integer(
      privateKey.privateExponent! % (privateKey.q! - BigInt.from(1)));
  ASN1Integer coefficient =
      ASN1Integer(privateKey.q!.modInverse(privateKey.p!));
  privateKeySequence.add(privateKeyVersion);
  privateKeySequence.add(modulus);
  privateKeySequence.add(publicExponent);
  privateKeySequence.add(privateExponent);
  privateKeySequence.add(prime1);
  privateKeySequence.add(prime2);
  privateKeySequence.add(exponent1);
  privateKeySequence.add(exponent2);
  privateKeySequence.add(coefficient);
  privateKeySequence.encode();
  ASN1OctetString privateKeyOctet = ASN1OctetString();
  privateKeyOctet.octets = privateKeySequence.encodedBytes;

  sequence.add(version);
  sequence.add(algorithm);
  sequence.add(privateKeyOctet);
  sequence.encode();
  return base64.encode(sequence.encodedBytes!);
}
