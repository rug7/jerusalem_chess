import 'package:flutter/material.dart';
import 'package:squares/squares.dart';
import 'package:flutter_chess_1/providers/custom_board_provider.dart';
import 'package:flutter_chess_1/providers/custom_piece_set.dart';

import 'custom_board_overlay.dart';

class CustomPieceOverlay extends StatelessWidget {
  final BoardSize size;

  /// Determines which way around the board is facing.
  /// 0 (white) will place the white pieces at the bottom,
  /// and 1 will place the black pieces there.
  /// You likely want to take this from `BoardState.orientation`.
  final int orientation;

  /// Pieces to draw on the board, at the indices specified by their keys.
  final Map<int, String> pieces;

  /// The set of widgets to use for pieces.
  final CustomPieceSet pieceSet;

  /// Opacity of the pieces.
  final double opacity;

  const CustomPieceOverlay({
    super.key,
    this.size = BoardSize.standard,
    this.orientation = Squares.white,
    required this.pieces,
    required this.pieceSet,
    this.opacity = Squares.defaultPremovePieceOpacity,
  });

  /// Creates a `PieceOverlay` with a single [piece], drawn at [square].
  factory CustomPieceOverlay.single({
    BoardSize size = BoardSize.standard,
    int orientation = Squares.white,
    required CustomPieceSet pieceSet,
    double opacity = Squares.defaultPremovePieceOpacity,
    required int square,
    required String piece,
  }) =>
      CustomPieceOverlay(
        size: size,
        orientation: orientation,
        pieces: {square: piece},
        pieceSet: pieceSet,
        opacity: opacity,
      );

  @override
  Widget build(BuildContext context) {
    return CustomBoardOverlay(
      size: size,
      orientation: orientation,
      children:
      pieces.map((sq, symbol) => MapEntry(sq, _piece(context, symbol))),
    );
  }

  Widget _piece(BuildContext context, String symbol) {
    return Opacity(
      opacity: opacity,
      child: pieceSet.piece(context, symbol),
    );
  }
}
