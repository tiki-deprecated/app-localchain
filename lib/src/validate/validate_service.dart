/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'validate_model.dart';
import 'validate_repository.dart';

class ValidateService {
  final ValidateRepository _repository;

  ValidateService(Database database)
      : _repository = ValidateRepository(database);

  Future<ValidateModel?> get last => _repository.findLast();

  Future<ValidateModel> start() =>
      _repository.insert(ValidateModel(started: DateTime.now()));

  Future<ValidateModel> pass(ValidateModel validate) =>
      _repository.update(validate);
}
