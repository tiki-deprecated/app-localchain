/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

part of crypto;

class CryptoKeyPair {
  final String public;
  final String private;

  CryptoKeyPair({required this.public, required this.private});

  @override
  String toString() {
    return 'KeyStoreCryptoKeyPair{public: $public, private: $private}';
  }
}
