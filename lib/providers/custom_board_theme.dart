import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

class CustomBoardTheme {
  final Color lightSquare;
  final Color darkSquare;
  final Color check;
  final Color checkmate;
  final Color previous;
  final Color selected;
  final Color premove;
  final AssetImage? logo;

  const CustomBoardTheme({
    required this.lightSquare,
    required this.darkSquare,
    required this.check,
    required this.checkmate,
    required this.previous,
    required this.selected,
    required this.premove,
    this.logo,
  });

  CustomBoardTheme copyWith({
    Color? lightSquare,
    Color? darkSquare,
    Color? check,
    Color? checkmate,
    Color? previous,
    Color? selected,
    Color? premove,
  }) =>
      CustomBoardTheme(
        lightSquare: lightSquare ?? this.lightSquare,
        darkSquare: darkSquare ?? this.darkSquare,
        check: check ?? this.check,
        checkmate: checkmate ?? this.checkmate,
        previous: previous ?? this.previous,
        selected: selected ?? this.selected,
        premove: premove ?? this.premove,
      );

  Color highlight(HighlightType type) => {
    HighlightType.check: check,
    HighlightType.checkmate: checkmate,
    HighlightType.previous: previous,
    HighlightType.selected: selected,
    HighlightType.premove: premove,
  }[type]!;

  /// Brown. Classic. Looks like chess.
  static const brown = CustomBoardTheme(
    lightSquare: Color(0xfff0d9b6),
    darkSquare: Color(0xffb58863),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809cc700),
    selected: Color(0x8014551e),
    premove: Color(0x80141e55),
  );

  /// A more modern blueish greyish theme.
  static const blueGrey = CustomBoardTheme(
    lightSquare: Color(0xfff0f5f7),
    darkSquare: Color(0xff0f659f),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x8014551e),
    premove: Color(0x807b56b3),
  );

  /// Eye pain theme.
  static const pink = CustomBoardTheme(
    lightSquare: Color(0xffeef0c7),
    darkSquare: Color(0xffe27c78),
    check: Color(0xffcb3927),
    checkmate: Colors.blue,
    previous: Color(0xff6ad1eb),
    selected: Color(0x8014551e),
    premove: Color(0x807b56b3),
  );

  /// A tribute.
  static const dart = CustomBoardTheme(
    lightSquare: Color(0xff41c4ff),
    darkSquare: Color(0xff0f659f),
    check: Color(0xffeb5160),
    checkmate: Color(0xff56351e),
    previous: Color(0x80a9fbd7),
    selected: Color(0x80f6f1d1),
    premove: Color(0x80e3d8f1),
  );

  static const goldGrey = CustomBoardTheme(
    lightSquare: Color(0xfff0f5f7),
    darkSquare: Color(0xfff0c230),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x8014551e),
    premove: Color(0x807b56b3),
  );

  static const blackGrey = CustomBoardTheme(
    lightSquare: Color(0xffc8bfd8),
    darkSquare: Color(0xff000000),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x8014551e),
    premove: Color(0x807b56b3),
  );

  static const purpleGrey = CustomBoardTheme(
    lightSquare: Color(0xfff0f5f7),
    darkSquare: Color(0xff663d99),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x8014551e),
    premove: Color(0x807b56b3),
    logo: AssetImage('assets/images/stockfish_1.png'),
  );
  static const goldPurple = CustomBoardTheme(
    lightSquare: Color(0xffc8bfd8),
    darkSquare: Color(0xff4e3c96),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x80f6f1d1),
    premove: Color(0x8014551e),
  );
  static const blackPurple = CustomBoardTheme(
    lightSquare: Color(0xff000000),
    darkSquare: Color(0xff663d99),
    check: Color(0xffeb5160),
    checkmate: Colors.orange,
    previous: Color(0x809bc700),
    selected: Color(0x80f6f1d1),
    premove: Color(0x8014551e),
  );


}
