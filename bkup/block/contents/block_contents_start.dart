/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_codec.dart';
import 'block_contents_schema.dart';

class BlockContentsStart extends BlockContents {
  String? start;

  BlockContentsStart({this.start}) : super(schema: BlockContentsSchema.start);

  @override
  Uint8List toBytes() =>
      encode(schema, Uint8List.fromList(utf8.encode(start!)));

  @override
  BlockContentsStart fromBytes(Uint8List bytes) {
    this.start = utf8.decode(bytes.sublist(1 + schema.length));
    return this;
  }

  @override
  String toString() {
    return 'BlockContentsBytea{schema:$schema, start:$start}';
  }
}
