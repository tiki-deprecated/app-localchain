/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'block_contents_confirm.dart';

import 'block_contents.dart';
import 'block_contents_bytea.dart';
import 'block_contents_data_nft.dart';
import 'block_contents_json.dart';
import 'block_contents_schema.dart';
import 'block_contents_start.dart';
import 'block_contents_uri_nft.dart';

const BlockContentsCodec contentsCodec = BlockContentsCodec();

class BlockContentsCodec {
  const BlockContentsCodec();

  Uint8List encode(BlockContents input) {
    BytesBuilder bytesBuilder = BytesBuilder();
    Uint8List schemaBytes = input.schema.bytes;
    if (schemaBytes.length > 0xff)
      throw FormatException(
          'schema types > than 255 bytes not supported', input);

    bytesBuilder.addByte(schemaBytes.length);
    bytesBuilder.add(schemaBytes);
    bytesBuilder.add(input.payload);

    return bytesBuilder.toBytes();
  }

  BlockContentsSchema? schema(Uint8List input) {
    try {
      return BlockContentsSchema.fromBytes(input.sublist(1, 1 + input[0]));
    } catch (error) {
      throw FormatException('failed to decode schema', input, 0);
    }
  }

  dynamic decode(Uint8List input) {
    BlockContentsSchema? contentsSchema = schema(input);
    if (contentsSchema == null)
      throw FormatException('cannot decode block, no schema', input, 0);
    Uint8List payload = input.sublist(1 + input[0]);

    switch (contentsSchema) {
      case BlockContentsSchema.json:
        return BlockContentsJson.payload(payload);
      case BlockContentsSchema.bytea:
        return BlockContentsBytea.payload(payload);
      case BlockContentsSchema.start:
        return BlockContentsStart.payload(payload);
      case BlockContentsSchema.dataNft:
        return BlockContentsDataNft.payload(payload);
      case BlockContentsSchema.uriNft:
        return BlockContentsUriNft.payload(payload);
      case BlockContentsSchema.confirm:
        return BlockContentsConfirm.payload(payload);
      default:
        return BlockContentsBytea.payload(payload);
    }
  }
}
