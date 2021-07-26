/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class KeyStoreException implements Exception {
  final String? address;
  final String message;

  KeyStoreException(this.message, {this.address});

  @override
  String toString() {
    return 'KeyStoreException{address: $address, message: $message}';
  }
}
