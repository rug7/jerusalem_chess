import 'package:flutter/material.dart';
import 'package:squares/squares.dart';
import 'package:flutter_chess_1/providers/custom_board_provider.dart';
import 'package:flutter_chess_1/providers/custom_piece_set.dart';

import '../main_screens/game_screen.dart';
import 'custom_board_theme.dart';
import 'custom_piece_overlay.dart';



class CustomBoardController extends StatefulWidget {
  final BoardState state;
  final PlayState playState;
  final CustomPieceSet pieceSet;
  final CustomBoardTheme theme;
  final BoardSize size;
  final MarkerTheme? markerTheme;
  final void Function(Move)? onMove;
  final void Function(Move?)? onSetPremove;
  final void Function(Move)? onPremove;
  final PromotionBehaviour promotionBehaviour;
  final List<String> pieceHierarchy;
  final List<Move> moves;
  final bool draggable;
  final double dragFeedbackSize;
  final Offset dragFeedbackOffset;
  final DragTargetFeedback? dragTargetFeedback;
  final bool animatePieces;
  final Duration animationDuration;
  final Curve animationCurve;
  final double premovePieceOpacity;
  final LabelConfig labelConfig;
  final BackgroundConfig backgroundConfig;
  final Widget? background;
  final double piecePadding;
  final List<Widget> underlays;
  final List<Widget> overlays;
  late final Map<int, List<Move>> moveMap;
  late final List<Move> drops;
  final String? lightModeLogo;
  final String? darkModeLogo;

  String get bestPiece =>
      pieceHierarchy.isNotEmpty ? pieceHierarchy.first : 'q';

  PlayerSet get dragPermissions => {
    PlayState.ourTurn: PlayerSet.fromPlayer(state.turn),
    PlayState.theirTurn: PlayerSet.fromPlayer(1 - state.turn),
    PlayState.observing: PlayerSet.both,
    PlayState.finished: PlayerSet.neither
  }[playState]!;

  CustomBoardController({
    super.key,
    required this.state,
    required this.playState,
    required this.pieceSet,
    this.theme = CustomBoardTheme.blueGrey,
    this.size = const BoardSize(8, 8),
    this.markerTheme,
    this.onMove,
    this.onSetPremove,
    this.onPremove,
    this.promotionBehaviour = PromotionBehaviour.alwaysSelect,
    this.pieceHierarchy = Squares.defaultPieceHierarchy,
    this.moves = const [],
    this.draggable = true,
    this.dragFeedbackSize = 2.0,
    this.dragFeedbackOffset = const Offset(0.0, -1.0),
    this.dragTargetFeedback,
    this.animatePieces = true,
    this.animationDuration = Squares.defaultAnimationDuration,
    this.animationCurve = Squares.defaultAnimationCurve,
    this.premovePieceOpacity = Squares.defaultPremovePieceOpacity,
    this.labelConfig = LabelConfig.standard,
    this.backgroundConfig = BackgroundConfig.standard,
    this.background,
    this.piecePadding = 0.0,
    this.overlays = const [],
    this.underlays = const [],
    this.lightModeLogo = 'assets/images/yellow_logo.svg',
    this.darkModeLogo = 'assets/images/purple_logo.svg',
  }) {
    moveMap = {};
    drops = [];
    for (Move m in moves) {
      if (m.handDrop) {
        drops.add(m);
        continue;
      }
      if (!moveMap.containsKey(m.from)) {
        moveMap[m.from] = [m];
      } else {
        moveMap[m.from]!.add(m);
      }
    }
  }

  @override
  State<CustomBoardController> createState() => _CustomBoardControllerState();
}

class _CustomBoardControllerState extends State<CustomBoardController> {
  int? selection;
  int? target;
  Move? premove;
  List<Move> dests = [];
  List<PieceSelectorData> pieceSelectors = [];
  String? get currentLogo => isLightMode ? widget.lightModeLogo : widget.darkModeLogo;

  int get player => widget.state.playerForState(widget.playState);

  @override
  void didUpdateWidget(covariant CustomBoardController oldWidget) {
    if (oldWidget.state != widget.state) {
      _onNewBoardState(oldWidget.state);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBoard(
      state: widget.state,
      playState: widget.playState,
      pieceSet: widget.pieceSet,
      theme: widget.theme,
      size: widget.size,
      markerTheme: widget.markerTheme,
      draggable: widget.draggable,
      dragFeedbackSize: widget.dragFeedbackSize,
      dragFeedbackOffset: widget.dragFeedbackOffset,
      dragPermissions: widget.dragPermissions,
      dragTargetFeedback: widget.dragTargetFeedback,
      animatePieces: widget.animatePieces,
      animationDuration: widget.animationDuration,
      animationCurve: widget.animationCurve,
      selection: selection,
      target: target,
      pieceSelectors: pieceSelectors,
      markers: dests.map((e) => e.to).toList(),
      onTap: _onTap,
      acceptDrag: _acceptDrag,
      validateDrag: _validateDrag,
      onPieceSelected: _onPieceSelected,
      labelConfig: widget.labelConfig,
      backgroundConfig: widget.backgroundConfig,
      background: widget.background,
      piecePadding: widget.piecePadding,
      underlays: widget.underlays,
      overlays: [
        ...widget.overlays,
        if (premove?.promotion ?? false)
          CustomPieceOverlay.single(
            size: widget.size,
            orientation: widget.state.orientation,
            pieceSet: widget.pieceSet,
            square: premove!.to,
            piece: pieceForPlayer(premove!.promo!, widget.state.waitingPlayer),
            opacity: widget.premovePieceOpacity,
          ),
        if (premove?.drop ?? false)
          CustomPieceOverlay.single(
            size: widget.size,
            orientation: widget.state.orientation,
            pieceSet: widget.pieceSet,
            square: premove!.dropSquare!,
            piece: pieceForPlayer(premove!.piece!, widget.state.waitingPlayer),
            opacity: widget.premovePieceOpacity,
          ),
      ],
    );
  }

  void _onNewBoardState(BoardState lastState) {
    if (widget.state.orientation != lastState.orientation) {
      // detect if the board has flipped
      _closePieceSelectors();
    }

    if (premove != null && widget.onPremove != null) {
      final premove = this.premove!;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onPremove!(premove));
    }

    if (selection != null) {
      if (premove == null) {
        _setSelection(selection!);
      } else {
        _clearSelection();
      }
    }

    if (target != null) {
      setState(() {
        premove = null;
        target = null;
        selection = null;
      });
    }
  }

  void _onTap(int square) {
    if (widget.playState == PlayState.ourTurn) {
      return _handleMoveTap(square, _onMove);
    }
    if (widget.playState == PlayState.theirTurn) {
      return _handleMoveTap(square, _setPremove, true);
    }
    setState(() => selection = square);
  }

  void _onPieceSelected(PieceSelectorData data, int index) {
    if (pieceSelectors.isEmpty || selection == null || widget.onMove == null) {
      return _closePieceSelectors();
    }
    String? piece = data.pieces[index];
    if (piece != null) piece = piece.toLowerCase();
    Move move = !data.gate
        ? Move(
      from: selection!,
      to: data.square,
      promo: piece,
    )
        : Move(
      from: selection!,
      to: data.square,
      piece: piece,
      gatingSquare: data.disambiguateGating ? data.gatingSquare : null,
    );
    if (widget.playState != PlayState.theirTurn) {
      if (widget.onMove != null) _onMove(move);
    } else {
      _setPremove(move);
    }
  }

  bool _validateDrag(PartialMove partial, int to) {
    if (partial.drop) {
      if (widget.drops.isEmpty) return false;
      return widget.drops.to(to).withPiece(partial.piece).isNotEmpty;
    }
    if (widget.moveMap[partial.from] == null) return false;
    Move? move =
    widget.moveMap[partial.from]!.firstWhereOrNull((m) => m.to == to);
    return move != null;
  }

  void _acceptDrag(PartialMove partial, int to) {
    if (partial.drop) {
      _onDrop(partial, to);
    } else {
      _setSelection(partial.from);
      // afterDrag = true;
      _onTap(to);
    }
  }

  void _handleMoveTap(
      int square,
      void Function(Move)? onMove, [
        bool isPremove = false,
      ]) {
    if (selection == null) {
      return _setSelection(square);
    }
    if (selection == square) {
      return _clearSelection();
    }
    final moves = dests.to(square);
    if (moves.isEmpty) {
      return _setSelection(square);
    }
    List<Move> promoMoves = moves.promoMoves;
    List<Move> gatingMoves = moves.gatingMoves;
    bool promoting = promoMoves.isNotEmpty;
    bool gating = gatingMoves.isNotEmpty;
    if (gating) {
      Set<int?> gatingSquares = {};
      for (Move m in gatingMoves) {
        gatingSquares.add(m.gatingSquare);
      }
      for (int? x in gatingSquares) {
        _openPieceSelector(
          square,
          gate: true,
          gatingSquare: x,
          disambiguateGating: gatingSquares.length > 1,
        );
      }
    } else if (promoting) {
      bool showSelector =
          widget.promotionBehaviour == PromotionBehaviour.alwaysSelect ||
              (!isPremove &&
                  widget.promotionBehaviour == PromotionBehaviour.autoPremove);
      if (!showSelector) {
        final m = promoMoves.bestPromo(widget.pieceHierarchy);
        if (m != null) {
          return onMove?.call(m);
        }
      }
      _openPieceSelector(square);
    } else {
      onMove?.call(moves.first);
    }
  }

  void _setSelection(int square) {
    setState(() {
      selection = square;
      target = null;
      dests = widget.moveMap[square] ?? [];
      pieceSelectors = [];
      premove = null;
    });
  }

  void _clearSelection() {
    setState(() {
      selection = null;
      target = null;
      dests = [];
      pieceSelectors = [];
    });
  }

  void _setTarget(int square) {
    setState(() {
      target = square;
      dests = [];
    });
  }

  void _onMove(Move move) {
    widget.onMove?.call(move);
    _clearSelection();
  }

  void _setPremove(Move move) {
    premove = move;
    _setTarget(move.to);
    _closePieceSelectors();
    widget.onSetPremove?.call(move);
  }

  void _openPieceSelector(
      int square, {
        bool gate = false,
        int? gatingSquare,
        bool disambiguateGating = false,
      }) {
    List<Move> moves = widget.moves
        .from(selection!)
        .to(square)
        .where(
          (e) => gate
          ? (e.gatingSquare == gatingSquare || e.gatingSquare == null)
          : true,
    )
        .toList();

    List<String?> pieces =
    moves.map<String?>((e) => gate ? e.piece : e.promo).toList();
    pieces.sort(_promoComp);
    if (player == Squares.white) {
      pieces = pieces.map<String?>((e) => e?.toUpperCase()).toList();
    }

    setState(() {
      pieceSelectors.add(
        PieceSelectorData(
          square: square,
          startLight: widget.size.isLightSquare(square),
          pieces: pieces,
          gate: gate,
          gatingSquare: gatingSquare,
          disambiguateGating: disambiguateGating,
        ),
      );
    });
  }

  void _closePieceSelectors() {
    setState(() => pieceSelectors = []);
  }

  int _promoComp(String? a, String? b) {
    if (a == null) return -1;
    if (b == null) return 1;
    return widget.pieceHierarchy
        .indexOf(a)
        .compareTo(widget.pieceHierarchy.indexOf(b));
  }

  void _onDrop(PartialMove partial, int to) {
    List<Move> targetMoves = widget.drops.to(to).withPiece(partial.piece);
    if (targetMoves.isEmpty) {
      _clearSelection();
    } else {
      if (widget.playState == PlayState.ourTurn) {
        _onMove(targetMoves.first);
      } else if (widget.playState == PlayState.theirTurn) {
        _setPremove(targetMoves.first);
      }
    }
  }
}
