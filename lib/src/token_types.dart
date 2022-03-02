typedef TT = TokenType;

enum TokenType {
  // Single-character tokens
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  comma,
  dot,
  minus,
  plus,
  semicolon,
  slash,
  star,

  // One/two-character tokens
  bang,
  bangEqual,
  equal,
  equalEqual,
  greater,
  greaterEqual,
  less,
  lessEqual,

  // Literals
  identifier,
  string,
  number,

  // Keywords
  $and,
  $class,
  $else,
  $false,
  $fun,
  $for,
  $if,
  $nil,
  $or,
  $print,
  $return,
  $super,
  $this,
  $true,
  $var,
  $while,

  eof
}
