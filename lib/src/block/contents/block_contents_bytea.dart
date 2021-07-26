/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_codec.dart';
import 'block_contents_schema.dart';

class BlockContentsBytea extends BlockContents {
  Uint8List? body;

  BlockContentsBytea({this.body}) : super(schema: BlockContentsSchema.bytea);

  @override
  Uint8List toBytes() => encode(schema, body);

  @override
  BlockContentsBytea fromBytes(Uint8List bytes) {
    this.body = bytes;
    return this;
  }

  @override
  String toString() {
    return 'BlockContentsBytea{schema:$schema, body:$body}';
  }
}
