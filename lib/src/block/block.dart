/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class Block {
  Uint8List? contents;
  Uint8List? previousHash;
  DateTime? created;

  Block({this.contents, this.previousHash, this.created});

  @override
  String toString() {
    return 'BlockModel{contents: $contents, previousHash: $previousHash, created: $created}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block &&
          runtimeType == other.runtimeType &&
          listEquals(contents, other.contents) &&
          listEquals(previousHash, other.previousHash) &&
          created == other.created;

  @override
  int get hashCode =>
      contents.hashCode ^ previousHash.hashCode ^ created.hashCode;
}
