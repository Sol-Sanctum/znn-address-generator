import 'dart:io';
import 'dart:math';

import 'package:bech32/bech32.dart';
import 'package:znn_address_generator/settings.dart';

isValid(String input) {
  // derived from Bech32 charset
  // List<String> invalidChars = ['1', 'b', 'i', 'o'];

  if (input.split('').map((c) => charset.contains(c)).every((e) => e) != true) {
    print('Error! ${input} is invalid');
    print('Valid characters are [a-z0-9], excluding 1, b, i, o.');
    exit(1);
  }

  if (Settings.prefix.length + Settings.suffix.length > 37) {
    print('Error! combined prefix and suffix length cannot exceed 37');
    exit(1);
  }
}

saveToFile(String data, {bool match = false}) async {
  bool findMatch = (Settings.prefix.isNotEmpty || Settings.suffix.isNotEmpty);

  if (match) {
    await File(Settings.filename).writeAsString(data, mode: FileMode.append);
  } else {
    if (findMatch && Settings.saveAll) {
      await File(Settings.allResults)
          .writeAsString(data, mode: FileMode.append);
    } else if (!findMatch) {
      await File(Settings.filename).writeAsString(data, mode: FileMode.append);
    }
  }
}

isMatch(String data) {
  RegExp regex = RegExp('^z1q${Settings.prefix}.*${Settings.suffix}\$');

  for (String line in data.split('\n')) {
    if (regex.hasMatch(line)) {
      // print('\nfound match: $line');
      return true;
    }
  }
  return false;
}

estimateTotal() {
  return pow(32, Settings.prefix.length + Settings.suffix.length) ~/
      Settings.addressesPerMnemonic;
}
