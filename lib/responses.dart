import 'dart:io';

import 'package:dcli/dcli.dart' hide Settings;
import 'package:znn_address_generator/settings.dart';

menu(String argsUsage) {
  print('Zenon Address Generator\n'
      'Usage: znn-address-generator [OPTIONS]\n\n'
      'Options\n'
      '${argsUsage}\n');
}

confirmSettings() {
  if (!confirm('Do you want to proceed?', defaultValue: true)) exit(0);
}

displaySettings() {
  bool findMatch = (Settings.prefix.isNotEmpty || Settings.suffix.isNotEmpty);

  print('---------------------------------------------------');
  print('Threads: ${Settings.threads}');
  if (!findMatch && !Settings.infinite) {
    print('Number of Mnemonics: ${Settings.numberOfMnemonics}');
  } else if (Settings.infinite) {
    print('Number of Mnemonics: infinite');
  }
  print('Addresses per mnemonic: ${Settings.addressesPerMnemonic}');
  print('Output file: ${Settings.filename}');
  print('Verbose output: ${Settings.verbose}');
  if (findMatch) {
    Settings.prefix.isNotEmpty
        ? print('Matching prefix: ${Settings.prefix}')
        : null;
    Settings.suffix.isNotEmpty
        ? print('Matching suffix: ${Settings.suffix}')
        : null;
    print('Save all mnemonics to separate file: ${Settings.saveAll}');
  }
  print('---------------------------------------------------');
}
