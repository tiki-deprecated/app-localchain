/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> rsaGenerate() async {
  return await compute(_rsaGenerate, "").then((keyPair) => keyPair);
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _rsaGenerate(_) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      keyPair.publicKey as RSAPublicKey, keyPair.privateKey as RSAPrivateKey);
}

String rsaEncodePublicKey(RSAPublicKey publicKey) {
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

RSAPublicKey rsaDecodePublicKey(String encodedKey) {
  ASN1Parser topLevelParser = new ASN1Parser(base64.decode(encodedKey));
  ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

  ASN1Sequence algorithmSeq = topLevelSeq.elements![0] as ASN1Sequence;
  ASN1BitString publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
  ASN1Sequence publicKeySeq =
      ASN1Sequence.fromBytes(publicKeyBitString.stringValues as Uint8List);

  ASN1Integer modulus = publicKeySeq.elements![0] as ASN1Integer;
  ASN1Integer exponent = publicKeySeq.elements![1] as ASN1Integer;
  return RSAPublicKey(modulus.integer!, exponent.integer!);
}

String rsaEncodePrivateKey(RSAPrivateKey privateKey) {
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

RSAPrivateKey rsaDecodePrivateKey(String encodedKey) {
  ASN1Parser topLevelParser = new ASN1Parser(base64.decode(encodedKey));
  ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

  ASN1Integer version = topLevelSeq.elements![0] as ASN1Integer;
  ASN1Sequence algorithmSeq = topLevelSeq.elements![1] as ASN1Sequence;
  ASN1OctetString privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;

  ASN1Sequence publicKeySeq =
      ASN1Sequence.fromBytes(privateKeyOctet.octets as Uint8List);
  ASN1Integer privateKeyVersion = publicKeySeq.elements![0] as ASN1Integer;
  ASN1Integer modulus = publicKeySeq.elements![1] as ASN1Integer;
  ASN1Integer publicExponent = publicKeySeq.elements![2] as ASN1Integer;
  ASN1Integer privateExponent = publicKeySeq.elements![3] as ASN1Integer;
  ASN1Integer prime1 = publicKeySeq.elements![4] as ASN1Integer;
  ASN1Integer prime2 = publicKeySeq.elements![5] as ASN1Integer;
  ASN1Integer exponent1 = publicKeySeq.elements![6] as ASN1Integer;
  ASN1Integer exponent2 = publicKeySeq.elements![7] as ASN1Integer;
  ASN1Integer coefficient = publicKeySeq.elements![8] as ASN1Integer;

  return RSAPrivateKey(modulus.integer!, privateExponent.integer!,
      prime1.integer, prime2.integer);
}

RSAPublicKey rsaPublicKey(RSAPrivateKey privateKey) {
  return RSAPublicKey(privateKey.modulus!, privateKey.publicExponent!);
}

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _rsaProcessInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(
        false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _rsaProcessInBlocks(decryptor, cipherText);
}

Uint8List _rsaProcessInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}
