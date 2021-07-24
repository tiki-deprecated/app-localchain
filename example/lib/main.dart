import 'package:flutter/material.dart';
import 'package:localchain/localchain.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}] ${record.time} | ${record.loggerName}: ${record.message}');
  });

  Localchain localchain = Localchain();
  await localchain.init();
  await localchain.keystore.generate();
  BlockModel block = await localchain.add("plaintext");

  runApp(MaterialApp(
    title: 'Localchain Example',
    theme: ThemeData(),
    home: Scaffold(
      body: Center(child: Text('Localchain')),
    ),
  ));
}
