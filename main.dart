import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';
import 'package:console_bars/console_bars.dart';
import 'package:dcli/dcli.dart';
import 'package:synchronized/synchronized.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

int threads = 10;
int numberOfMnemonics = 100;
int addressesPerMnemonic = 5;
String filename = 'results.txt';
bool verbose = false;

String argsUsage = '';

FillingBar bar = FillingBar(total: 0);

main(List<String> args) async {
  parseArgs(args);

  print('---------------------------------------------------');
  print('Threads: ${threads}');
  print('Number of Mnemonics: ${numberOfMnemonics}');
  print('Addresses per mnemonic: ${addressesPerMnemonic}');
  print('Output file: ${filename}');
  print('Verbose output: ${verbose}');
  print('---------------------------------------------------');
  if (!confirm('Do you want to proceed?', defaultValue: true)) exit(0);

  if (!verbose) {
    bar = FillingBar(
      desc: "Generating",
      total: numberOfMnemonics,
      time: true,
      percentage: true,
      scale: 0.4,
      width: 50,
    );
  }

  var receivePort = new ReceivePort();
  var lock = new Lock();
  int complete = 0;
  String resultCache = '';

  List<Future<Isolate>> spawns = [];
  for (var i = 0; i++ < threads;) {
    spawns.add(Isolate.spawn(generateAddresses, receivePort.sendPort));
  }

  await for (var result in receivePort) {
    if (verbose) {
      stdout.write(result);
    } else {
      bar.increment();
    }
    resultCache += result;
    complete++;

    if (complete % 10 == 0) {
      lock.synchronized(() async => await File(filename)
          .writeAsString(resultCache, mode: FileMode.append));
      resultCache = '';
    }

    if (complete >= numberOfMnemonics) {
      if (complete % 10 != 0) {
        lock.synchronized(() async => await File(filename)
            .writeAsString(resultCache, mode: FileMode.append));
      }
      return;
    }
    spawns.add(Isolate.spawn(generateAddresses, receivePort.sendPort));
  }
  print("\nDone");
  exit(0);
}

generateAddresses(port) async {
  var store = await KeyStore.newRandom();
  String result = '${store.mnemonic}\n';

  for (var l in await store.deriveAddressesByRange(0, addressesPerMnemonic)) {
    result += '${l.toString()}\n';
  }
  Isolate.exit(port, ('$result\n'));
}

menu() {
  print('Zenon Address Generator\n'
      'Usage: znn-address-generator [OPTIONS]\n\n'
      'Options\n'
      '${argsUsage}\n');
}

parseArgs(List<String> args) {
  final ArgParser argParser = ArgParser();
  argParser.addOption('threads',
      abbr: 't', defaultsTo: '4', help: 'number of cpu threads');
  argParser.addOption('mnemonics',
      abbr: 'n', defaultsTo: '100', help: 'number of mnemonics to generate');
  argParser.addOption('addresses',
      abbr: 'a', defaultsTo: '5', help: 'number of addresses per mnemonic');
  argParser.addOption('output',
      abbr: 'o', defaultsTo: 'results.txt', help: 'output file name');
  argParser.addFlag('verbose',
      abbr: 'v',
      negatable: false,
      defaultsTo: false,
      help: 'display mnemonics as they\'re being generated');
  argParser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Displays help information');

  final argResult = argParser.parse(args);
  argsUsage = argParser.usage;

  if (argResult['help'] || argResult.arguments.isEmpty) {
    menu();
    exit(0);
  }

  if (argResult.wasParsed('threads')) {
    threads = int.parse(argResult['threads']);
  }

  if (argResult.wasParsed('mnemonics')) {
    numberOfMnemonics = int.parse(argResult['mnemonics']);
  }

  if (argResult.wasParsed('addresses')) {
    addressesPerMnemonic = int.parse(argResult['addresses']);
  }

  if (argResult.wasParsed('output')) {
    filename = argResult['output'];
  }

  if (argResult['verbose']) {
    verbose = true;
  }
}
