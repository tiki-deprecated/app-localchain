/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class ValidateModel {
  int? id;
  DateTime? started;
  bool? didPass;

  ValidateModel({this.id, this.started, this.didPass});

  ValidateModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.id = map['id'];
      if (map['pass_bool'] != null)
        this.didPass = map['pass_bool'] == 1 ? true : false;
      if (map['started_epoch'] != null)
        this.started =
            DateTime.fromMillisecondsSinceEpoch(map['started_epoch']);
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'started_epoch': started?.millisecondsSinceEpoch,
        'pass_bool': didPass == true ? 1 : 0
      };
}
