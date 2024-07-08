// import 'package:bishop/bishop.dart';
// import 'package:flutter/material.dart';
//
// import '../providers/custom_board_provider.dart';
// import '../providers/custom_board_state.dart';
// import '../providers/custom_board_theme.dart';
// import '../providers/custom_piece_set.dart';
//
//
// class GameAnalysisScreen extends StatefulWidget {
//   final List<String> moves;
//
//   const GameAnalysisScreen({Key? key, required this.moves}) : super(key: key);
//
//   @override
//   State<GameAnalysisScreen> createState() => _GameAnalysisScreenState();
// }
//
// class _GameAnalysisScreenState extends State<GameAnalysisScreen> {
//   late Game _game;
//   late int _moveIndex;
//   late CustomBoardState _state;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeGame();
//   }
//
//   void _initializeGame() {
//     _game = Game(variant: Variant.standard());
//     _moveIndex = 0;
//     _state = _convertToCustomBoardState(_game.state as CustomBoardState);
//   }
//
//   CustomBoardState _convertToCustomBoardState(CustomBoardState states) {
//     final lastMove = _game.history.isNotEmpty ? _game.history.last.move : null;
//     return CustomBoardState(
//       board: states.board.map((piece) => piece.toString()).toList(),
//       turn: states.turn,
//       lastFrom: lastMove?.from,
//       lastTo: lastMove?.to,
//       checkSquare: states.checkSquare,
//       orientation: states.turn,
//     );
//   }
//
//   void _goToMove(int index) {
//     _initializeGame();
//     for (int i = 0; i <= index; i++) {
//       _game.makeMoveString(widget.moves[i]);
//     }
//
//     setState(() {
//       _moveIndex = index;
//       _state = _convertToCustomBoardState(_game.state as CustomBoardState);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final pieceSet = CustomPieceSet(
//       pieces: {
//         'P': (context) => Image.asset('assets/pieces/white_pawn.png'),
//         'p': (context) => Image.asset('assets/pieces/black_pawn.png'),
//         'R': (context) => Image.asset('assets/pieces/white_rook.png'),
//         'r': (context) => Image.asset('assets/pieces/black_rook.png'),
//         'N': (context) => Image.asset('assets/pieces/white_knight.png'),
//         'n': (context) => Image.asset('assets/pieces/black_knight.png'),
//         'B': (context) => Image.asset('assets/pieces/white_bishop.png'),
//         'b': (context) => Image.asset('assets/pieces/black_bishop.png'),
//         'Q': (context) => Image.asset('assets/pieces/white_queen.png'),
//         'q': (context) => Image.asset('assets/pieces/black_queen.png'),
//         'K': (context) => Image.asset('assets/pieces/white_king.png'),
//         'k': (context) => Image.asset('assets/pieces/black_king.png'),
//       },
//     );
//
//     final theme = CustomBoardTheme.blueGrey;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Game Analysis')),
//       body: Column(
//         children: [
//           CustomBoard(
//             state: _state,
//             pieceSet: pieceSet,
//             theme: theme,
//             onTap: (int index) {
//               // Handle square tap if needed
//             },
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left),
//                 onPressed: _moveIndex > 0 ? () {
//                   _goToMove(_moveIndex - 1);
//                 } : null,
//               ),
//               IconButton(
//                 icon: const Icon(Icons.chevron_right),
//                 onPressed: _moveIndex < widget.moves.length - 1 ? () {
//                   _goToMove(_moveIndex + 1);
//                 } : null,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// Future<void> saveGameToUserHistory(String gameId, List<String> moves) async {//TODO MOVES URGENT
//   if (gameId.isEmpty) {
//     print('Game ID is empty');
//     return;
//   }
//   try {
//     final gameSnapshot = await firebaseFirestore.collection(Constants.runningGames).doc(gameId).get();
//     if (gameSnapshot.exists) {
//       final gameData = gameSnapshot.data() as Map<String, dynamic>;
//
//       String gameCreatorUid = gameData[Constants.gameCreatorUid];
//       String opponentUid = gameData[Constants.userId];
//       String gameCreatorName = gameData[Constants.gameCreatorName];
//       String opponentName = gameData[Constants.userName];
//       String creationTime = gameData[Constants.dateCreated];
//       List<String> validMoves = moves.where(isValidMove).toList();
//
//
//       String formattedCreationTime = formatTimestamp(creationTime);
//
//
//       await firebaseFirestore.collection(Constants.users).doc(gameCreatorUid).update({
//         Constants.gameHistory: FieldValue.arrayUnion([{
//           'opponentName': opponentName,
//           'creationTime': formattedCreationTime ,
//           'moves': validMoves,
//         }])
//
//       });
//
//       await firebaseFirestore.collection(Constants.users).doc(opponentUid).update({
//         Constants.gameHistory: FieldValue.arrayUnion([{
//           'opponentName': gameCreatorName,
//           'creationTime': formattedCreationTime ,
//           'moves': validMoves,
//         }])
//       });
//     }
//   } catch (e) {
//     print('Failed to save game history: $e');
//   }
// }

// Future<void> updateUserGameHistory(String userId, Map<String, dynamic> newGame) async {
//   DocumentReference userRef = firebaseFirestore.collection(Constants.users).doc(userId);
//   print("new game :$newGame");
//
//   try {
//     // Fetch the user data
//     DocumentSnapshot userSnapshot = await userRef.get();
//     if (userSnapshot.exists) {
//       Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
//
//       // Update the user's game history
//       List<dynamic> gameHistory = userData[Constants.gameHistory] ?? [];
//       gameHistory.add(newGame);
//
//       await userRef.update({
//         Constants.gameHistory: gameHistory,
//       });
//     }
//   } catch (e) {
//     print('Error updating game history: $e');
//   }
// }