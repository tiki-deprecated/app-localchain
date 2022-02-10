/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsUriNft extends BlockContents {
  Uri? uri;

  BlockContentsUriNft({this.uri}) : super(BlockContentsSchema.uriNft);

  BlockContentsUriNft.path(String path) : super(BlockContentsSchema.uriNft) {
    try {
      uri = Uri.parse(path);
    } catch (error) {
      throw FormatException('failed to parse path', path);
    }
  }

  BlockContentsUriNft.payload(Uint8List bytes)
      : super(BlockContentsSchema.uriNft) {
    try {
      uri = Uri.parse(utf8.decode(bytes));
    } catch (error) {
      throw FormatException('failed to decode block', bytes);
    }
  }

  @override
  Uint8List get payload => Uint8List.fromList(utf8.encode(uri.toString()));

  @override
  String toString() {
    return 'BlockContentsUriNft{_schema: $schema, uri: $uri}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BlockContentsUriNft &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => super.hashCode ^ uri.hashCode;
}
