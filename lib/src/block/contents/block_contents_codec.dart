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

const BlockContentsCodec contentsCodec = BlockContentsCodec();

class BlockContentsCodec extends Codec<BlockContents, Uint8List> {
  const BlockContentsCodec();

  @override
  Converter<Uint8List, BlockContents> get decoder => BlockContentsDecoder();

  @override
  Converter<BlockContents, Uint8List> get encoder => BlockContentsEncoder();
}

class BlockContentsDecoder extends Converter<Uint8List, BlockContents> {
  @override
  BlockContents convert(Uint8List input) {
    BlockContentsSchema? schema =
        BlockContentsSchema.fromBytes(input.sublist(1, 1 + input[0]));
    Uint8List payload = input.sublist(1 + input[0]);

    switch (schema) {
      case BlockContentsSchema.json:
        return BlockContentsJson.payload(payload);
      case BlockContentsSchema.bytea:
      default:
        return BlockContentsBytea.payload(payload);
    }
  }
}

class BlockContentsEncoder extends Converter<BlockContents, Uint8List> {
  @override
  Uint8List convert(BlockContents input) {
    BytesBuilder bytesBuilder = BytesBuilder();
    Uint8List schemaBytes = input.schema.bytes;
    if (schemaBytes.length > 0xff)
      throw StateError('schema types > than 255 bytes not supported');

    bytesBuilder.addByte(schemaBytes.length);
    bytesBuilder.add(schemaBytes);
    bytesBuilder.add(input.payload);

    return bytesBuilder.toBytes();
  }
}
