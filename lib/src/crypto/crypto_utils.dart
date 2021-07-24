/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

String sha3(String raw) {
  final SHA3Digest sha3256 = SHA3Digest(256);
  Uint8List hash = sha3256.process(utf8.encode(raw) as Uint8List);
  return hash.map((b) => '${b.toRadixString(16).padLeft(2, '0')}').join("");
}

FortunaRandom _secureRandom() {
  var secureRandom = new FortunaRandom();
  var random = new Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) seeds.add(random.nextInt(255));
  secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));
  return secureRandom;
}
