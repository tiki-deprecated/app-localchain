/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

Future<CryptoKeyPair> ecdsaGenerate() async {
  return await compute(_ecdsaGenerate, "").then((keyPair) => keyPair);
}

CryptoKeyPair _ecdsaGenerate(_) {
  final ECKeyGeneratorParameters keyGeneratorParameters =
      ECKeyGeneratorParameters(ECCurve_secp256r1());
  ECKeyGenerator ecKeyGenerator = ECKeyGenerator();
  ecKeyGenerator
      .init(ParametersWithRandom(keyGeneratorParameters, _secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair =
      ecKeyGenerator.generateKeyPair();
  return CryptoKeyPair(
      public: _ecdsaEncodePublicKey(keyPair.publicKey as ECPublicKey),
      private: _ecdsaEncodePrivateKey(keyPair.privateKey as ECPrivateKey));
}

String _ecdsaEncodePublicKey(ECPublicKey publicKey) {
  ASN1Sequence sequence = ASN1Sequence();
  ASN1Sequence algorithm = ASN1Sequence();
  algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
  algorithm.add(ASN1ObjectIdentifier.fromName('prime256v1'));
  ASN1BitString publicKeyBitString = ASN1BitString();
  publicKeyBitString.stringValues = publicKey.Q!.getEncoded(false);
  sequence.add(algorithm);
  sequence.add(publicKeyBitString);
  sequence.encode();
  return base64.encode(sequence.encodedBytes!);
}

String _ecdsaEncodePrivateKey(ECPrivateKey privateKey) {
  ASN1Sequence sequence = ASN1Sequence();
  ASN1Integer version = ASN1Integer(BigInt.from(0));
  ASN1Sequence algorithm = ASN1Sequence();
  algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
  algorithm.add(ASN1ObjectIdentifier.fromName('prime256v1'));

  ASN1Sequence encodedPrivateKey = ASN1Sequence();
  ASN1Integer encodedPrivateKeyVersion = ASN1Integer(BigInt.from(1));
  ASN1OctetString encodedPrivateKeyValue = ASN1OctetString();
  ASN1Integer encodePrivateKeyBigInt = ASN1Integer(privateKey.d);
  encodePrivateKeyBigInt.encode();
  encodedPrivateKeyValue.octets = encodePrivateKeyBigInt.valueBytes;
  encodedPrivateKey.add(encodedPrivateKeyVersion);
  encodedPrivateKey.add(encodedPrivateKeyValue);
  encodedPrivateKey.encode();

  ASN1OctetString privateKeyDer = ASN1OctetString();
  privateKeyDer.octets = encodedPrivateKey.encodedBytes;

  sequence.add(version);
  sequence.add(algorithm);
  sequence.add(privateKeyDer);
  sequence.encode();
  return base64.encode(sequence.encodedBytes!);
}
