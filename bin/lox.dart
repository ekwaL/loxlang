import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lox/src/lexer.dart';

const usageInfo = """
Usage:
lox [script]  to run script
lox           to run REPL
""";

const replWelcomeMessage = """
This is a Lox REPL.
More info on usage later.
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
      exit(64);
  }
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

Stream<String> _readLine() =>
    stdin.transform(utf8.decoder).transform(const LineSplitter());



String _lineNumberToString(int line) {
  if (line ~/ 10 == 0) return "00$line";
  if (line ~/ 100 == 0) return "0$line";
  return line.toString();
}
