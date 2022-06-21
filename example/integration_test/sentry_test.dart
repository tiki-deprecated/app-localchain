import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logging/logging.dart';
import 'package:tiki_localchain/tiki_localchain.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Log Error Tests', () {
    test("runzoneguarded catch uncaught errors", () async {
      bool errorCaught = false;
      await runZonedGuarded(() async {
        Logger.root.level = Level.INFO;
        Logger.root.onRecord.listen((record) => errorCaught = true);
        WidgetsFlutterBinding.ensureInitialized();
        TikiLocalchain localchain = await TikiLocalchain().open(Uuid().v4());
        Uint8List contents = Uint8List.fromList("random stuff".codeUnits);
        await localchain.append([contents]);
        await localchain.validate();
        FlutterError.onError = (FlutterErrorDetails details) {
          Logger("Flutter Error").severe(details.summary, details.exception, details.stack);
        };
        runApp(Container());
      }, (exception, stackTrace) async {
        Logger("Uncaught Exception").severe("Caught by runZoneGuarded", exception, stackTrace);
      });
      expect(errorCaught,true);
    });
  });
}