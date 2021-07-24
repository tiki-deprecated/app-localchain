/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class KeyStoreException implements Exception {
  String? address;
  String message;

  KeyStoreException(this.message, {this.address});

  @override
  String toString() {
    return 'KeyStoreException{address: $address, message: $message}';
  }
}
