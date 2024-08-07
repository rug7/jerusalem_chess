import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

import 'custom_piece_set.dart';


/// The piece layer for a board. Contains pieces and empty boxes.
class CustomBoardPieces extends StatefulWidget {
  /// The set of widgets to use for pieces on the board.
  final CustomPieceSet pieceSet;

  /// The state of the board - which pieces are on which squares, etc.
  final BoardState state;

  /// Dimensions of the board.
  final BoardSize size;

  /// Are the pieces draggable?
  final bool draggable;

  /// If true and there is a last move, it will be animated.
  final bool animatePieces;

  /// How long move animations take to play.
  final Duration animationDuration;

  /// Animation curve for piece movements.
  /// Defaults to [Curves.easeInQuad].
  final Curve animationCurve;

  /// Called when a piece is tapped.
  final void Function(int)? onTap;

  /// Called when a drag is started.
  final void Function(int)? onDragStarted;

  /// Called when a drag is cancelled.
  final void Function(int)? onDragCancelled;

  /// Called when a drag ends, i.e. a piece was dropped on a target.
  final void Function(int)? onDragEnd;

  /// If set to true, all gestures will be ignored by this layer.
  /// Generally useful if you have an external drag (e.g. from a hand) happening.
  final bool ignoreGestures;

  /// Padding to add on every side of a piece, relative to the size of the
  /// square it is on. For example, 0.05 will add 5% padding to each side.
  final double piecePadding;

  /// Which players' pieces we can drag.
  final PlayerSet dragPermissions;

  const CustomBoardPieces({
    super.key,
    required this.pieceSet,
    required this.state,
    this.size = BoardSize.standard,
    this.draggable = true,
    this.animatePieces = true,
    this.animationDuration = Squares.defaultAnimationDuration,
    this.animationCurve = Squares.defaultAnimationCurve,
    this.onTap,
    this.onDragStarted,
    this.onDragCancelled,
    this.onDragEnd,
    this.ignoreGestures = false,
    this.piecePadding = 0.0,
    this.dragPermissions = PlayerSet.both,
  });

  @override
  State<CustomBoardPieces> createState() => _CustomBoardPiecesState();
}

class _CustomBoardPiecesState extends State<CustomBoardPieces> {
  int? currentDrag;
  bool animate = true;
  bool afterDrag = false; // track drags so they're not animated

  @override
  void didUpdateWidget(covariant CustomBoardPieces oldWidget) {
    // This prevents the animation from repeating in cases where it shouldn't,
    // e.g. if the board is rotated. It would also be possible to do this with
    // collection's ListEquality or something but this seems efficient.
    animate =
        oldWidget.state.board.join() != widget.state.board.join() && !afterDrag;
    afterDrag = false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.ignoreGestures,
      child: BoardBuilder(
        size: widget.size,
        builder: (rank, file, squareSize) =>
            _piece(context, rank, file, squareSize),
      ),
    );
  }

  Widget _piece(BuildContext context, int rank, int file, double squareSize) {
    int id = widget.size.square(rank, file, widget.state.orientation);
    String symbol =
    widget.state.board.length > id ? widget.state.board[id] : '';


    Widget piece = symbol.isNotEmpty
        ? widget.pieceSet.piece(context, symbol)
        : Container();
    int? player = symbol.isEmpty
        ? null
        : symbol.toLowerCase() == symbol
        ? Squares.black
        : Squares.white;
    bool draggable = widget.draggable &&
        player != null &&
        widget.dragPermissions.forPlayer(player);
    final p = SizedBox(
      width: squareSize,
      height: squareSize,
      child: Padding(
        padding: EdgeInsets.all(widget.piecePadding * squareSize),
        child: Piece(
          draggable: currentDrag != null ? currentDrag == id : draggable,
          interactible: currentDrag == null || currentDrag == id,
          move: PartialMove(
            from: id,
            piece: symbol,
          ),
          onTap: () => widget.onTap?.call(id),
          onDragStarted: () => _onDragStarted(id),
          onDragCancelled: () => _onDragCancelled(id),
          onDragEnd: (details) => _onDragEnd(id, details),
          child: piece,
        ),
      ),
    );
    if (widget.state.lastTo == id &&
        widget.state.lastFrom != Squares.hand &&
        symbol.isNotEmpty &&
        widget.animatePieces &&
        animate) {
      int orientation = widget.state.orientation == Squares.white ? 1 : -1;
      return MoveAnimation(
        x: -widget.size
            .fileDiff(widget.state.lastFrom!, widget.state.lastTo!)
            .toDouble() *
            orientation,
        y: widget.size
            .rankDiff(widget.state.lastFrom!, widget.state.lastTo!)
            .toDouble() *
            orientation,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        child: p,
      );
    }
    return p;
  }

  void _onDragStarted(int id) {
    setState(() => currentDrag = id);
    widget.onDragStarted?.call(id);
  }

  void _onDragCancelled(int id) {
    setState(() => currentDrag = null);
    widget.onDragCancelled?.call(id);
  }

  void _onDragEnd(int id, DraggableDetails details) {
    setState(() {
      currentDrag = null;
      if (details.wasAccepted) afterDrag = true;
    });
    widget.onDragEnd?.call(id);
  }
}
