import 'package:intl/intl.dart';

class Settings {
  static int threads = 4;
  static int numberOfMnemonics = 100;
  static int addressesPerMnemonic = 5;

  static String time = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  static String filename = './results/results-${time}.txt';
  static String allResults = './results/allresults-${time}.txt';

  static String prefix = '';
  static String suffix = '';

  static bool verbose = false;
  static bool saveAll = false;
  static bool infinite = false;
}
