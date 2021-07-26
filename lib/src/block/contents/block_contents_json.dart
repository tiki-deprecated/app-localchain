/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:localchain/src/block/contents/block_contents_schema.dart';

import 'block_contents.dart';
import 'block_contents_codec.dart';

class BlockContentsJson extends BlockContents {
  String? json;

  BlockContentsJson({this.json}) : super(schema: BlockContentsSchema.json);

  @override
  Uint8List toBytes() => encode(schema, Uint8List.fromList(utf8.encode(json!)));

  @override
  BlockContentsJson fromBytes(Uint8List bytes) {
    this.json = utf8.decode(bytes.sublist(1 + schema.length));
    return this;
  }

  @override
  String toString() {
    return 'BlockContentsJson{schema:$schema json: $json}';
  }
}
