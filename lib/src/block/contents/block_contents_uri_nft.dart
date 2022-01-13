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

  BlockContentsUriNft.payload(Uint8List bytes)
      : uri = Uri.parse(utf8.decode(bytes)),
        super(BlockContentsSchema.uriNft);

  @override
  Uint8List get payload => Uint8List.fromList(utf8.encode(uri.toString()));

  @override
  String toString() {
    return 'BlockContentsUriNft{_schema: $schema, uri: $uri}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockContentsUriNft &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => uri.hashCode;
}
