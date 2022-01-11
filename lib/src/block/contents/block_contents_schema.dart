/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

class BlockContentsSchema {
  final int _code;

  static const BlockContentsSchema bytea = BlockContentsSchema(0);
  static const BlockContentsSchema start = BlockContentsSchema(1);
  static const BlockContentsSchema json = BlockContentsSchema(2);
  static const BlockContentsSchema nft = BlockContentsSchema(3);
  static const BlockContentsSchema dataNft = BlockContentsSchema(4);

  static const List<BlockContentsSchema> all = [
    bytea,
    start,
    json,
    nft,
    dataNft
  ];

  const BlockContentsSchema(this._code);

  int get code => _code;

  Uint8List get bytes {
    int i = _code;
    List<int> bytes = [];
    bytes.insert(0, i & 0xff);
    i >>= 8;
    while (i > 0) {
      bytes.insert(0, i & 0xff);
      i >>= 8;
    }
    return Uint8List.fromList(bytes);
  }

  static BlockContentsSchema? fromCode(int code) {
    try {
      return all.firstWhere((element) => element.code == code);
    } catch (error) {
      return null;
    }
  }

  static BlockContentsSchema? fromBytes(Uint8List bytes) {
    int val = 0;
    for (int i = 0; i < bytes.length; i++) {
      val <<= 8;
      val += bytes[i];
    }
    return fromCode(val);
  }
}
