# znn-address-generator

Concurrently generate mnemonics and addresses, then save them to disk.  
Optionally generate addresses with specific prefixes and suffixes.

## Setup
```bash
git clone https://github.com/Sol-Sanctum/znn-address-generator.git && cd znn-address-generator
dart pub get
dart run main.dart -n 1000
```

## Releases
Download compiled versions of the generator [here](https://github.com/Sol-Sanctum/znn-address-generator/releases/latest).  

**MacOS Example**
```bash
wget https://github.com/Sol-Sanctum/znn-address-generator/releases/download/master/znn-address-generator-macos
chmod +x ./znn-address-generator-macos
```

## Options
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
-p, --prefix       save addresses that match a specific prefix
-s, --suffix       save addresses that match a specific suffix
-i, --infinite     generate infinite mnemonics
    --all          save all generated mnemonics, even if they don't match
-v, --verbose      display mnemonics as they're being generated
-h, --help         Displays help information
```

## Usage
You can mix and match whatever settings you want.  
#### Generate 1000 mnemonics with 8 threads
```bash
znn-address-generator -n 1000 -t 8
```

#### Find an address with suffix 321
```bash
znn-address-generator -s 321
```

#### Find an address with prefix zzz and suffix 321
```bash
znn-address-generator -prefix zzz -s 321
```

#### Find an address with suffix 321 and save all results that don't match to a separate file
```bash
znn-address-generator -s 321 --all
```

#### Find as many addresses with suffix 321
```bash
znn-address-generator -s 321 --infinite
Note: Ctrl-C to end execution
```