
import 'dart:io';

void error(int line, String message) {
  report(line, "", message);
}

void report(int line, String where, String message) {
  stderr.writeln("[line $line] Error $where: $message");
}
