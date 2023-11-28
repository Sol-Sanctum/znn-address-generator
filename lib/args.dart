import 'dart:io';

import 'package:args/args.dart';
import 'package:znn_address_generator/responses.dart';
import 'package:znn_address_generator/settings.dart';

import 'helper.dart';

parseArgs(List<String> args) async {
  final ArgParser argParser = ArgParser();
  argParser.addOption('threads',
      abbr: 't', defaultsTo: '4', help: 'number of cpu threads');
  argParser.addOption('mnemonics',
      abbr: 'n', defaultsTo: '100', help: 'number of mnemonics to generate');
  argParser.addOption('addresses',
      abbr: 'a', defaultsTo: '5', help: 'number of addresses per mnemonic');
  argParser.addOption('output',
      abbr: 'o',
      defaultsTo: './results/results-<time>.txt',
      help: 'output file name');
  argParser.addOption('prefix',
      abbr: 'p', help: 'save addresses that match a specific prefix');
  argParser.addOption('suffix',
      abbr: 's', help: 'save addresses that match a specific suffix');
  argParser.addFlag('infinite',
      abbr: 'i',
      negatable: false,
      defaultsTo: false,
      help: 'generate infinite mnemonics');
  argParser.addFlag('all',
      negatable: false,
      defaultsTo: false,
      help: 'save all generated mnemonics, even if they don\'t match');
  argParser.addFlag('verbose',
      abbr: 'v',
      negatable: false,
      defaultsTo: false,
      help: 'display mnemonics as they\'re being generated');
  argParser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Displays help information');

  final argResult = argParser.parse(args);
  String argsUsage = argParser.usage;

  if (argResult['help'] || argResult.arguments.isEmpty) {
    menu(argsUsage);
    exit(0);
  }

  if (argResult.wasParsed('threads')) {
    Settings.threads = int.parse(argResult['threads']);
    if (Settings.threads < 1) {
      print('Error! You must use at least one thread');
      exit(1);
    }
  }

  if (argResult.wasParsed('mnemonics')) {
    Settings.numberOfMnemonics = int.parse(argResult['mnemonics']);
    if (Settings.numberOfMnemonics < 1) {
      print('Error! You must generate at least one mnemonic');
      exit(1);
    }
  }

  if (argResult.wasParsed('addresses')) {
    Settings.addressesPerMnemonic = int.parse(argResult['addresses']);
    if (Settings.addressesPerMnemonic < 1) {
      print('Error! You must generate at least one address per mnemonic');
      exit(1);
    }
  }

  if (argResult.wasParsed('prefix')) {
    List<String> firstChars = ['p', 'q', 'r', 'z'];
    Settings.prefix = argResult['prefix'].toString().toLowerCase();
    isValid(Settings.prefix);
    if (!firstChars.contains(Settings.prefix[0])) {
      print(
          'Error! The prefix should start with one of these letters: p, q, r, z');
      exit(1);
    }
  }

  if (argResult.wasParsed('suffix')) {
    Settings.suffix = argResult['suffix'].toString().toLowerCase();
    isValid(Settings.suffix);
  }

  if (argResult.wasParsed('output')) {
    Settings.filename = argResult['output'];
  } else {
    await Directory('./results').create(recursive: true);
  }

  if (argResult['verbose']) {
    Settings.verbose = true;
  }

  if (argResult['all']) {
    Settings.saveAll = true;
  }

  if (argResult['infinite']) {
    Settings.infinite = true;
  }
}
