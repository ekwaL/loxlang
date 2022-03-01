#!/bin/bash

dart run ../tools/ast_generator.dart $1
dart format $1
