/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

Future<Uint8List> aesGenerate() async {
  return await compute(_aesGenerate, "").then((key) => key);
}

Uint8List _aesGenerate(_) {
  FortunaRandom secureRandom = _secureRandom();
  return secureRandom.nextBytes(32);
}

Uint8List aesEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
  //TODO should be uuid to force uniqueness
  //TODO auto-pad plaintext

  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );

  return cipher.process(plaintext);
}

Uint8List aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List cipherText) {
  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      false,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );

  return cipher.process(cipherText);
}

void _aesLengthValidate(
    Uint8List key, Uint8List iv, Uint8List paddedPlaintext) {
  if (key.length != 256 && key.length != 192 && key.length != 128)
    throw FormatException("key length must be 128-bits, 192-bits or 256-bits");

  if (iv.length != 128) throw FormatException("iv length must be 128-bits");

  //TODO padded plaintext must be divisible by 128
}
