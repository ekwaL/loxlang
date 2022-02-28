import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../lib/lox.dart';
import '../lib/src/char_codes.dart';

const usageInfo = """
Usage:
lox [script]  to run script
lox           to run REPL
""";

void main(List<String> arguments) {
  switch (arguments.length) {
    case 0:
      _runREPL();
      break;
    case 1:
      _runFile(arguments[0]);
      break;
    default:
      print(usageInfo);
      codes();
      exit(64);
  }
}

void _runREPL() {
  repl(stdin, stdout);
}

void _runFile(String path) {
  // if (await FileSystemEntity.isDirectory(path)) {
  //   stderr.writeln('error: $path is a directory');
  // }
  try {
    final sourceFile = File(path);
    // TODO: Throws a FormatException
    // https://api.dart.dev/stable/2.16.1/dart-convert/Utf8Decoder-class.html
    Stream<String> sourceCode = sourceFile.openRead().transform(utf8.decoder);
  } catch (error) {
    stderr
        .writeln('Could not open file $path : $error'); // or can not decode it
  } finally {
    // sourceFile.clo
  }
  // f.openRead()
}
