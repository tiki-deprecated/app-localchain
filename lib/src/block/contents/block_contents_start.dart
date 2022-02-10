/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsStart extends BlockContents {
  String? start;

  BlockContentsStart({this.start}) : super(BlockContentsSchema.start);

  BlockContentsStart.payload(Uint8List bytes)
      : super(BlockContentsSchema.start) {
    try {
      start = utf8.decode(bytes);
    } catch (error) {
      throw FormatException('failed to decode block', bytes);
    }
  }

  @override
  Uint8List get payload => Uint8List.fromList(utf8.encode(start ?? ''));

  @override
  String toString() {
    return 'BlockContentsStart{_schema: $schema, start: $start}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BlockContentsStart &&
          runtimeType == other.runtimeType &&
          start == other.start;

  @override
  int get hashCode => super.hashCode ^ start.hashCode;
}
