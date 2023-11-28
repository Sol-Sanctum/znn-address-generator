import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:console_bars/console_bars.dart';
import 'package:synchronized/synchronized.dart';
import 'package:znn_address_generator/args.dart';
import 'package:znn_address_generator/helper.dart';
import 'package:znn_address_generator/responses.dart';
import 'package:znn_address_generator/settings.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

FillingBar bar = FillingBar(total: 0);

main(List<String> args) async {
  parseArgs(args);
  displaySettings();
  confirmSettings();

  bool findMatch = (Settings.prefix.isNotEmpty || Settings.suffix.isNotEmpty);

  if (!Settings.verbose) {
    if (findMatch) {
      bar = FillingBar(
        desc: "Finding matches",
        total: estimateTotal(),
        time: true,
        scale: 0.4,
        width: 50,
      );
    } else {
      bar = FillingBar(
        desc: "Generating",
        total: Settings.numberOfMnemonics,
        time: true,
        percentage: true,
        scale: 0.4,
        width: 50,
      );
    }
  }

  var receivePort = new ReceivePort();
  var lock = new Lock();
  int complete = 0;
  String resultCache = '';

  List<Future<Isolate>> spawns = [];
  for (var i = 0; i++ < Settings.threads;) {
    spawns.add(Isolate.spawn(generateAddresses,
        [receivePort.sendPort, Settings.addressesPerMnemonic]));
  }

  await for (var result in receivePort) {
    if (Settings.verbose) {
      stdout.write(result);
    } else {
      bar.increment();
    }

    if (findMatch) {
      if (isMatch(result)) {
        await saveToFile(result, match: true);
        if (!Settings.infinite) {
          print('\n\nFound a match!');
          print(result);
          exit(0);
        }
      }
    }

    resultCache += result;
    complete++;

    if (complete % 10 == 0) {
      lock.synchronized(() async => await saveToFile(resultCache));
      resultCache = '';
    }

    if (complete >= Settings.numberOfMnemonics &&
        !Settings.infinite &&
        !findMatch) {
      if (complete % 10 != 0) {
        lock.synchronized(() async => await saveToFile(resultCache));
      }
      return;
    }
    spawns.add(Isolate.spawn(generateAddresses,
        [receivePort.sendPort, Settings.addressesPerMnemonic]));
  }
  print("\nDone");
  exit(0);
}

generateAddresses(List<dynamic> args) async {
  SendPort port = args[0];
  int addressesPerMnemonic = args[1];

  var store = await KeyStore.newRandom();
  String result = '${store.mnemonic}\n';

  for (var l in await store.deriveAddressesByRange(0, addressesPerMnemonic)) {
    result += '${l.toString()}\n';
  }
  Isolate.exit(port, ('$result\n'));
}
