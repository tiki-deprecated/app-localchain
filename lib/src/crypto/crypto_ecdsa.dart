/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

Future<AsymmetricKeyPair<ECPublicKey, ECPrivateKey>> ecdsaGenerate() async {
  return await compute(_ecdsaGenerate, "").then((keyPair) => keyPair);
}

AsymmetricKeyPair<ECPublicKey, ECPrivateKey> _ecdsaGenerate(_) {
  final ECKeyGeneratorParameters keyGeneratorParameters =
      ECKeyGeneratorParameters(ECCurve_secp256r1());

  ECKeyGenerator ecKeyGenerator = ECKeyGenerator();
  ecKeyGenerator
      .init(ParametersWithRandom(keyGeneratorParameters, _secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair =
      ecKeyGenerator.generateKeyPair();
  return AsymmetricKeyPair<ECPublicKey, ECPrivateKey>(
      keyPair.publicKey as ECPublicKey, keyPair.privateKey as ECPrivateKey);
}

String ecdsaEncodePublicKey(ECPublicKey publicKey) {
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

ECPublicKey ecdsaDecodePublicKey(String encodedKey) {
  ASN1Parser topLevelParser = new ASN1Parser(base64.decode(encodedKey));
  ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

  ASN1Sequence algorithmSeq = topLevelSeq.elements![0] as ASN1Sequence;
  ASN1BitString publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;

  String curveName =
      (algorithmSeq.elements![1] as ASN1ObjectIdentifier).readableName!;
  ECDomainParameters ecDomainParameters = ECDomainParameters(curveName);
  ECPoint? Q =
      ecDomainParameters.curve.decodePoint(publicKeyBitString.stringValues!);

  return ECPublicKey(Q, ecDomainParameters);
}

String ecdsaEncodePrivateKey(ECPrivateKey privateKey) {
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

ECPrivateKey ecdsaDecodePrivateKey(String encodedKey) {
  ASN1Parser topLevelParser = new ASN1Parser(base64.decode(encodedKey));
  ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

  ASN1Integer version = topLevelSeq.elements![0] as ASN1Integer;
  ASN1Sequence algorithmSeq = topLevelSeq.elements![1] as ASN1Sequence;
  ASN1OctetString privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;

  String curveName =
      (algorithmSeq.elements![1] as ASN1ObjectIdentifier).readableName!;
  ECDomainParameters ecDomainParameters = ECDomainParameters(curveName);

  ASN1Sequence privateKeySeq =
      ASN1Sequence.fromBytes(privateKeyOctet.octets as Uint8List);
  ASN1Integer privateKeyVersion = privateKeySeq.elements![0] as ASN1Integer;
  ASN1OctetString privateKeyValue =
      privateKeySeq.elements![1] as ASN1OctetString;
  ASN1Integer privateKeyBigInt =
      ASN1Integer.fromBytes(privateKeyValue.encodedBytes!);

  return ECPrivateKey(privateKeyBigInt.integer, ecDomainParameters);
}

ECPublicKey ecdsaPublicKey(ECPrivateKey privateKey) {
  ECPoint? Q = privateKey.parameters!.G * privateKey.d;
  return ECPublicKey(Q, privateKey.parameters);
}

Uint8List ecdsaSign(ECPrivateKey privateKey, Uint8List message) {
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(
      true,
      ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(privateKey), _secureRandom()));
  ECSignature signature = signer.generateSignature(message) as ECSignature;

  BytesBuilder bytesBuilder = BytesBuilder();
  Uint8List encodedR = encodeBigInt(signature.r);
  bytesBuilder.addByte(encodedR.length);
  bytesBuilder.add(encodedR);
  bytesBuilder.add(encodeBigInt(signature.s));
  return bytesBuilder.toBytes();
}

bool ecdsaVerify(
    ECPublicKey publicKey, Uint8List signature, Uint8List message) {
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(false, PublicKeyParameter<ECPublicKey>(publicKey));

  int rLength = signature[0];
  Uint8List encodedR = signature.sublist(1, 1 + rLength);
  Uint8List encodedS = signature.sublist(1 + rLength);
  ECSignature ecSignature =
      ECSignature(decodeBigInt(encodedR), decodeBigInt(encodedS));

  return signer.verifySignature(message, ecSignature);
}
