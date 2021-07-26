/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

FortunaRandom _secureRandom() {
  var secureRandom = new FortunaRandom();
  var random = new Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) seeds.add(random.nextInt(255));
  secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));
  return secureRandom;
}

/// Encode a BigInt into bytes using big-endian encoding.
/// It encodes the integer to a minimal twos-compliment integer as defined by
/// ASN.1
/// From pointycastle/src/utils
Uint8List encodeBigInt(BigInt? number) {
  if (number == BigInt.zero) {
    return Uint8List.fromList([0]);
  }

  int needsPaddingByte;
  int rawSize;

  if (number! > BigInt.zero) {
    rawSize = (number.bitLength + 7) >> 3;
    needsPaddingByte =
        ((number >> (rawSize - 1) * 8) & BigInt.from(0x80)) == BigInt.from(0x80)
            ? 1
            : 0;
  } else {
    needsPaddingByte = 0;
    rawSize = (number.bitLength + 8) >> 3;
  }

  final size = rawSize + needsPaddingByte;
  var result = Uint8List(size);
  for (var i = 0; i < rawSize; i++) {
    result[size - i - 1] = (number! & BigInt.from(0xff)).toInt();
    number = number >> 8;
  }
  return result;
}

/// Decode a BigInt from bytes in big-endian encoding.
/// Twos compliment.
/// From pointycastle/src/utils
BigInt decodeBigInt(List<int> bytes) {
  var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;

  BigInt result;

  if (bytes.length == 1) {
    result = BigInt.from(bytes[0]);
  } else {
    result = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      var item = bytes[bytes.length - i - 1];
      result |= (BigInt.from(item) << (8 * i));
    }
  }
  return result != BigInt.zero
      ? negative
          ? result.toSigned(result.bitLength)
          : result
      : BigInt.zero;
}
