import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

import 'custom_board_background.dart';
import 'custom_board_theme.dart';
import 'custom_bord_pieces.dart';
import 'custom_label_overlay.dart';
import 'custom_piece_selector.dart';
import 'custom_piece_set.dart';
import 'package:flutter_svg/flutter_svg.dart';


/// The visual representation of the board. Can be used by itself to simply display
/// a board, or in conjunction with [BoardController] or some other wrapper to
/// manage its state and handle interactions.
class CustomBoard extends StatelessWidget {
  /// The state of the board - which pieces are on which squares, etc.
  final BoardState state;

  /// The set of widgets to use for pieces on the board.
  final CustomPieceSet pieceSet;

  /// Colour scheme for the board.
  final CustomBoardTheme theme;

  /// Dimensions of the board.
  final BoardSize size;

  /// Widget builders for the various types of square markers used.
  late final MarkerTheme markerTheme;

  /// The currently selected square index.
  final int? selection;

  /// The currently selected target square index (for premoves).
  final int? target;

  /// The state of the game, from the perspective of the player.
  final PlayState playState;

  /// Configuration of visible piece selectors (for promo and gating).
  final List<PieceSelectorData> pieceSelectors;

  /// Whether pieces should be draggable or not.
  final bool draggable;

  /// The size of pieces being dragged will be multiplied by this.
  /// 1.5 is a good value for mobile, but 1.0 is preferable for web.
  final double dragFeedbackSize;

  /// A vector to offset the position of dragged pieces by, relative to the size of the piece.
  /// No offset is recommended for web, and Offset(0,-1) for mobile, in which case
  /// the bottom of the piece will be anchored to the finger.
  final Offset dragFeedbackOffset;

  /// Which players' pieces we can drag.
  final PlayerSet dragPermissions;

  /// Builds feedback for squares being hovered over by a dragged piece.
  final DragTargetFeedback? dragTargetFeedback;

  /// Called when a square is tapped.
  final void Function(int)? onTap;

  /// Called when a piece selector receives user input.
  final void Function(PieceSelectorData data, int i)? onPieceSelected;

  /// Called when a piece drag is cancelled.
  final void Function(int)? onDragCancel;

  /// Called when a piece moves over a new square. This includes external pieces,
  /// such as those that came from hands.
  final bool Function(PartialMove, int)? validateDrag;

  /// Called when a square accepts a piece dragged onto it.
  final void Function(PartialMove, int)? acceptDrag;

  /// A list of highlighted square indices. Usually this will correspond to squares
  /// that the selected piece can move to.
  final List<int> markers;

  /// If true and there is a last move, it will be animated.
  final bool animatePieces;

  /// How long move animations take to play.
  final Duration animationDuration;

  /// Animation curve for piece movements.
  /// Defaults to [Curves.easeInQuad].
  final Curve animationCurve;

  /// A list of widgets that will be inserted between the board background and
  /// the piece layer. Ensure these don't absorb any gestures to preserve board
  /// behaviour.
  final List<Widget> underlays;

  /// A list of widgets that will be inserted on top of the piece layer, but
  /// below any visible piece selectors. Ensure these don't absorb any gestures
  /// to preserve board behaviour.
  final List<Widget> overlays;

  /// Set this to true if an external drag is in progress.
  /// When true, this disables the gesture detectors on the piece layer,
  /// allowing external drags to land.
  final bool externalDrag;

  /// Configuration for the rank and file labels on the board.
  /// Set this to LabelConfig.disabled to hide them entirely.
  final LabelConfig labelConfig;

  /// Configuration for the background. Determines which squares to draw, and
  /// allows an opacity for squares to be defined.
  final BackgroundConfig backgroundConfig;

  /// A widget to be placed behind everything on the board.
  /// Useful for games with backgrounds like Xiangqi.
  /// If you use this then you need to either set [boardConfig] or set the colour
  /// of the basic squares in [theme] to transparent.
  final Widget? background;

  /// Padding to add on every side of a piece, relative to the size of the
  /// square it is on. For example, 0.05 will add 5% padding to each side.
  final double piecePadding;

  ///for the h1 logo
  final String? h1SquareImage;


  List<Widget> _generateUnderlays(double squareSize) {
    List<Widget> customUnderlays = List<Widget>.from(underlays); // Start with existing underlays

    if (h1SquareImage != null) {
      // Assuming h1 is at the bottom-right and boardPadding is the padding around the board
      double leftOffset = (size.h - 1) * squareSize + 9 ; // right-most column
      double topOffset = (size.v - 1) * squareSize + 5  ; // bottom row for white's perspective


      // Add the SVG image widget for the h1 square
      customUnderlays.add(
        Positioned(
          left: leftOffset,
          top: topOffset,
          child: IgnorePointer(
            child: SvgPicture.asset(
              h1SquareImage!,
              width: squareSize*0.9,
              height: squareSize*0.9,
            ),
          ),
        ),
      );
    }
    return customUnderlays;
  }



  CustomBoard({
    super.key,
    required this.state,
    this.playState = PlayState.observing,
    required this.pieceSet,
    this.theme = CustomBoardTheme.blueGrey,
    this.size = BoardSize.standard,
    MarkerTheme? markerTheme,
    this.selection,
    this.target,
    this.pieceSelectors = const [],
    this.draggable = true,
    this.dragFeedbackSize = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),
    this.dragPermissions = PlayerSet.both,
    this.dragTargetFeedback,
    this.onTap,
    this.onPieceSelected,
    this.onDragCancel,
    this.validateDrag,
    this.acceptDrag,
    this.markers = const [],
    this.animatePieces = true,
    this.animationDuration = Squares.defaultAnimationDuration,
    this.animationCurve = Squares.defaultAnimationCurve,
    this.underlays = const [],
    this.overlays = const [],
    this.externalDrag = false,
    this.labelConfig = LabelConfig.standard,
    this.backgroundConfig = BackgroundConfig.standard,
    this.background,
    this.piecePadding = 0.0,
    this.h1SquareImage,
  }) : markerTheme = markerTheme ?? MarkerTheme.basic;


  @override
  Widget build(BuildContext context) {
    // const double boardPadding = -10; // You may need to adjust this value
    return AspectRatio(
      aspectRatio: size.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double squareSize = constraints.maxWidth / size.h;
          List<Widget> boardUnderlays = _generateUnderlays(squareSize); // Pass the padding value here
          return Stack(
            children: [
              if (background != null) background!,
              CustomBoardBackground(
                config: backgroundConfig,
                size: size,
                orientation: state.orientation,
                theme: theme,
                highlights: generateHighlights(
                  state: state,
                  selection: selection,
                  target: target,
                  playState: playState,
                ),
                markers: generateMarkers(
                  state: state,
                  squares: markers,
                  colour: playState != PlayState.theirTurn
                      ? HighlightType.selected
                      : HighlightType.premove,
                ),
                markerTheme: markerTheme,
              ),
              if (labelConfig.showLabels)
                CustomLabelOverlay(
                  config: labelConfig,
                  size: size,
                  orientation: state.orientation,
                  theme: theme,
                ),
              BoardTargets(
                size: size,
                orientation: state.orientation,
                onTap: onTap,
                validateDrag: validateDrag,
                acceptDrag: acceptDrag,
                feedback: dragTargetFeedback,
              ),
              ...boardUnderlays,
              CustomBoardPieces(
                pieceSet: pieceSet,
                state: state,
                size: size,
                onTap: onTap,
                onDragStarted: onTap,
                animatePieces: animatePieces,
                animationDuration: animationDuration,
                animationCurve: animationCurve,
                ignoreGestures: externalDrag,
                piecePadding: piecePadding,
                dragPermissions: dragPermissions,
              ),
              ...overlays,
              for (PieceSelectorData data in pieceSelectors)
                CustomPositionedPieceSelector(
                  data: data,
                  boardState: state,
                  boardSize: size,
                  theme: theme,
                  pieceSet: pieceSet,
                  squareSize: squareSize,
                  onTap: (i) => onPieceSelected?.call(data, i),
                ),
            ],
          );
        },
      ),
    );
  }
}
