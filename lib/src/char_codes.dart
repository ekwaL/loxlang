void codes() {
  final alpha = "azAZ_";
  final digits = "1234567890";
  final spc = ' \r\t\n';
  final str = '(){},.-+;*/!=<>"\'';
  for (final rune in (alpha + digits + str + spc).runes) {
    print("const = $rune; // ${String.fromCharCode(rune)}");
  }
}

// Decimal char codes
const leftParen = 40; // (
const rightParen = 41; // )
const leftBrace = 123; // {
const rightBrace = 125; // }
const comma = 44; // ,
const dot = 46; // .
const minus = 45; // -
const plus = 43; // +
const semicolon = 59; // ;
const slash = 47; // /
const star = 42; // *

const bang = 33; // !
const equal = 61; // =
const greater = 62; // >
const less = 60; // <
const doubleQuote = 34; // "
const singleQuote = 39; // '
const whitespace = 32; //
const carriageReturn = 13; //
const tab = 9; //
const newLine = 10; //

const endOfText = 3;
const endOfTransmission = 4;
const symbolNull = 0;

const underscore = 95;

bool isDigit(int? rune) {
  if (rune == null) return false;
  if (rune < 48) return false;
  if (rune > 57) return false;
  return true;
}

bool isAlpha(int? rune) {
  if (rune == null) return false;
  if (rune >= 97 && rune <= 122) return true; // a - z
  if (rune >= 65 && rune <= 90) return true; // a - z
  if (rune == underscore) return true; // a - z
  return false;
}

bool isAlphaNumeric(int? rune) => isDigit(rune) || isAlpha(rune);
