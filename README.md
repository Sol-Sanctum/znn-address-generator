# znn-address-generator

Concurrently generate mnemonics and addresses, then save them to disk.

### Setup
```bash
git clone https://github.com/Sol-Sanctum/znn-address-generator.git && cd znn-address-generator
dart pub get
dart run main.dart
```

### Releases
Download compiled versions of the generator [here](https://github.com/Sol-Sanctum/znn-address-generator/releases/latest).

### Options
```bash
Zenon Address Generator
Usage: znn-address-generator [OPTIONS]

Options
-t, --threads      number of cpu threads
                   (defaults to "4")
-n, --mnemonics    number of mnemonics to generate
                   (defaults to "100")
-a, --addresses    number of addresses per mnemonic
                   (defaults to "5")
-o, --output       output file name
                   (defaults to "results.txt")
-v, --verbose      display mnemonics as they're being generated
-h, --help         Displays help information
```