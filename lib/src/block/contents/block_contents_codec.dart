/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_bytea.dart';
import 'block_contents_json.dart';
import 'block_contents_schema.dart';

BlockContents decode(Uint8List bytes) {
  int schemaLength = bytes[0];
  String schema = utf8.decode(bytes.sublist(1, 1 + schemaLength));

  switch (schema) {
    case BlockContentsSchema.json:
      return BlockContentsJson().fromBytes(bytes);
    case BlockContentsSchema.bytea:
    default:
      return BlockContentsBytea().fromBytes(bytes);
  }
}

Uint8List encode(String schema, Uint8List? body) {
  BytesBuilder bytesBuilder = BytesBuilder();
  bytesBuilder.addByte(schema.length);
  bytesBuilder.add(Uint8List.fromList(utf8.encode(schema)));
  if (body != null) bytesBuilder.add(body);
  return bytesBuilder.toBytes();
}
