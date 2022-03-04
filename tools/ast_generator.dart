import 'dart:io';

const usageInfo = """
Usage:
ast_generator [output file path]
""";

void main(List<String> arguments) {
  if (arguments.length != 1) {
    print(usageInfo);
    exit(64);
  }

  final outputDir = arguments[0];

  _defineAst(
    outputDir,
    "Expr",
    [
      "Assign   : Token name, Expr value",
      "Binary   : Expr left, Token operator, Expr right",
      "Call     : Expr callee, Token paren, List<Expr> arguments",
      "Grouping : Expr expression",
      "Literal  : Object? value",
      "Logical  : Expr left, Token operator, Expr right",
      "Unary    : Token operator, Expr right",
      "Variable : Token name",
    ],
    [
      "src/token.dart",
    ],
  );

  _defineAst(
    outputDir,
    "Stmt",
    [
      "Block          : List<Stmt> statements",
      "ExpressionStmt : Expr expression",
      "FunctionStmt   : Token name, List<Token> params, List<Stmt> body",
      "IfStmt         : Expr condition, Stmt thenBranch, Stmt? elseBranch",
      "Print          : Expr expression",
      "Return         : Token keyword, Expr? value",
      "Var            : Token name, Expr? initializer",
      "While          : Expr condition, Stmt body",
    ],
    [
      "src/expr.dart",
      "src/token.dart",
    ],
  );
}

void _defineAst(
  String outputDir,
  String baseName,
  List<String> types,
  List<String> imports,
) {
  final fileName = baseName.toLowerCase() + ".dart";
  final outputFile = outputDir.endsWith('/')
      ? outputDir + fileName
      : outputDir + "/" + fileName;
  final IOSink writer;
  try {
    writer = File(outputFile).openWrite(); // (encoding: utf8);
  } catch (err) {
    print("Can not open $outputFile for writing : $err");
    exit(64);
  }

  writer.writeln("""
  ${imports.map((i) => "import 'package:lox/$i';").join("\n")}

  """);

  writer.writeln("""
  abstract class $baseName {
    const $baseName();

    R accept<R>(${baseName}Visitor<R> visitor);
  }
  """);

  _defineVisitor(writer, baseName, types.map((t) => t.split(":")[0].trim()));

  for (final type in types) {
    final className = type.split(":")[0].trim();
    final fields = type.split(":")[1].trim().split(", ");
    _defineType(writer, baseName, className, fields);
  }

  writer.close();
}

_defineType(
  IOSink writer,
  String baseName,
  String className,
  List<String> fields,
) {
  writer.writeln("""
  class $className extends $baseName {
    ${fields.map((f) => "final $f;").join("\n")}

    const $className({
      ${fields.map((f) => "required this.${f.split(" ")[1]},").join("\n")}
    });

    @override
    R accept<R>(${baseName}Visitor<R> visitor) {
      return visitor.visit$className$baseName(this);
    }
  }
  """);
}

_defineVisitor(IOSink writer, String baseName, Iterable<String> classNames) {
  final methodNames = classNames
      .map((typeName) =>
          "R visit$typeName$baseName($typeName ${baseName.toLowerCase()});")
      .join("\n");
  writer.writeln("""
  abstract class ${baseName}Visitor<R> {
    $methodNames
  }
  """);
}

// _format(String filePath) {
//   var shell = Shell();

//   shell.run("""
//     #!/bin/bash
//     /usr/bin/osascript -e 'do shell script "dscacheutil -flushcache  2>&1 etc" with administrator privileges'
//     """).then((result) {
//     print('Shell script done!');
//   }).catchError((onError) {
//     print('Shell.run error!');
//     print(onError);
//   });
// }

// class GenerateAst {}
