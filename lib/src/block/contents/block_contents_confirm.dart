/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsConfirm extends BlockContents {
  String? txn;
  DateTime? timestamp;

  BlockContentsConfirm({this.txn, this.timestamp})
      : super(BlockContentsSchema.confirm);

  BlockContentsConfirm.payload(Uint8List bytes)
      : super(BlockContentsSchema.confirm) {
    try {
      int txnLen = bytes.elementAt(0);
      Uint8List txnBytes = bytes.sublist(1, 1 + txnLen);
      int tsLen = bytes.elementAt(1 + txnLen);
      Uint8List tsBytes = bytes.sublist(2 + txnLen, 2 + txnLen + tsLen);
      txn = utf8.decode(txnBytes);
      timestamp = DateTime.parse(utf8.decode(tsBytes));
    } catch (error) {
      throw FormatException('failed to decode block', bytes);
    }
  }

  @override
  Uint8List get payload {
    BytesBuilder builder = BytesBuilder();
    if (txn == null) throw FormatException('transaction required');
    if (timestamp == null) throw FormatException('timestamp required');

    Uint8List txnBytes = Uint8List.fromList(utf8.encode(txn!));
    Uint8List tsBytes =
        Uint8List.fromList(utf8.encode(timestamp!.toIso8601String()));

    if (txnBytes.length > 255)
      throw FormatException('fingerprint byte[] length must be < 255', txn);

    if (tsBytes.length > 255)
      throw FormatException('proof byte[] length must be < 255', timestamp);

    builder.addByte(txnBytes.length);
    builder.add(txnBytes);
    builder.addByte(tsBytes.length);
    builder.add(tsBytes);
    return builder.toBytes();
  }

  @override
  String toString() {
    return 'BlockContentsConfirm{_schema: $schema, txn: $txn, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BlockContentsConfirm &&
          runtimeType == other.runtimeType &&
          txn == other.txn &&
          timestamp == other.timestamp;

  @override
  int get hashCode => super.hashCode ^ txn.hashCode ^ timestamp.hashCode;
}
