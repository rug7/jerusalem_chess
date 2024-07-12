// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chess_1/helper/helper_methods.dart';
// import 'package:flutter_chess_1/helper/uci_commands.dart';
// import 'package:flutter_chess_1/models/user_model.dart';
// import 'package:flutter_chess_1/providers/authentication_provider.dart';
// import 'package:flutter_chess_1/providers/game_provider.dart';
// import 'package:flutter_chess_1/providers/custom_board_controller_provider.dart';
// import 'package:flutter_chess_1/service/assests_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:squares/squares.dart';
// import 'package:stockfish/stockfish.dart';
//
// import '../constants.dart';
// import '../providers/custom_board_theme.dart';
// import '../providers/custom_piece_set.dart';
// import 'home_screen.dart';
//
// bool isLightMode = true;
//
// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});
//
//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> {
//   late Stockfish stockfish;
//   List<String> moveList = []; // List to store moves
//
//   @override
//   void initState() {
//     stockfish = Stockfish();
//     final gameProvider = context.read<GameProvider>();
//     gameProvider.resetGame(newGame: false);
//     super.initState();
//     if (!gameProvider.vsComputer) {
//       gameProvider.listenToGameUpdates();
//     }
//
//     if (mounted) {
//       letOtherPlayerPlayFirst();
//     }
//
//     stockfish.stdout.listen((event) {
//       if (event.contains(UCICommands.bestMove)) {
//         final bestMove = event.split(' ')[1];
//         final newLocation = bestMove.substring(2);
//         final beforeFen = gameProvider.getPositionFen();
//         gameProvider.makeStringMove(bestMove);
//         final afterFen = gameProvider.getPositionFen();
//
//         // Log before and after FEN
//         print("Before Move FEN: $beforeFen");
//         print("After Move FEN: $afterFen");
//         final moveDetails = getMoveDetails(beforeFen, afterFen);
//         print("Stockfish Move Details: ${moveDetails['movedPiece']} ${moveDetails['specialMove']} ${moveDetails['capturedPiece']}");
//         gameProvider.setAiThinking(false);
//         gameProvider.setSquaresState().whenComplete(() {
//           if (gameProvider.player == Squares.white) {
//             // Check if we can play white's timer
//             if (gameProvider.playWhiteTimer) {
//               // Pause timer for black
//               gameProvider.pauseBlackTimer();
//               startTimer(
//                 isWhiteTimer: true,
//                 onNewGame: () {},
//               );
//
//               gameProvider.setPlayWhiteTimer(value: false);
//             }
//           } else {
//             if (gameProvider.playBlackTimer) {
//               // Pause timer for white
//               gameProvider.pauseWhiteTimer();
//               startTimer(
//                 isWhiteTimer: false,
//                 onNewGame: () {},
//               );
//
//               gameProvider.setPlayBlackTimer(value: false);
//             }
//           }
//         });
//         //updateMoveList(newLocation);
//       }
//       print("moveList: $moveList");
//     });
//
//   }
//
//   @override
//   void dispose() {
//     stockfish.dispose();
//     super.dispose();
//   }
//   bool isValidMove(String move) {
//     // Ensure the move matches the chess notation format like "e2-e4"
//     final moveRegExp = RegExp(r'^[a-h][1-8]-[a-h][1-8]$');
//     return moveRegExp.hasMatch(move);
//   }
//
//   // Function to update move list
//   void updateMoveList(String moveDetails, bool isCapture) {
//     setState(() {
//       if (isCapture) {
//         moveList.add("${moveDetails}x$moveDetails");
//       } else if (moveDetails.isNotEmpty) {
//         moveList.add("$moveDetails $moveDetails");
//       } else {
//         moveList.add(moveDetails);
//       }
//     });
//   }
//
//
//   void _onMove(Move move) async {
//     final gameProvider = context.read<GameProvider>();
//     final beforeFen = gameProvider.getPositionFen();
//     bool result = gameProvider.makeSquaresMove(move);
//     final afterFen = gameProvider.getPositionFen();
//
//     // Log before and after FEN
//     print("Before Move FEN: $beforeFen");
//     print("After Move FEN: $afterFen");
//
//     // Get move details
//     final moveDetails = getMoveDetails(beforeFen, afterFen);
//     print("Human Move Details: ${moveDetails['movedPiece']} ${moveDetails['specialMove']} ${moveDetails['capturedPiece']}");
//
//     if (result) {
//       updateMoveList(moveDetails.toString(), moveDetails.isNotEmpty);
//       gameProvider.setSquaresState().whenComplete(() async {
//         if (gameProvider.player == Squares.white) {
//           if (gameProvider.vsComputer) {
//             gameProvider.pauseWhiteTimer();
//             startTimer(isWhiteTimer: false, onNewGame: () {});
//             gameProvider.setPlayWhiteTimer(value: true);
//           } else {
//             await gameProvider.playMoveAndSaveToFirestore(context: context, move: move, isWhitesMove: true);
//           }
//         } else {
//           if (gameProvider.vsComputer) {
//             gameProvider.pauseBlackTimer();
//             startTimer(isWhiteTimer: true, onNewGame: () {});
//             gameProvider.setPlayBlackTimer(value: true);
//           } else {
//             await gameProvider.playMoveAndSaveToFirestore(context: context, move: move, isWhitesMove: false);
//           }
//         }
//         print('moves: $moveList');
//       });
//     }
//
//     if (gameProvider.vsComputer) {
//       if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
//         gameProvider.setAiThinking(true);
//         await waitUntilReady();
//         stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';
//         int depth = 1; // Default depth
//         if (gameProvider.gameLevel == 1) {
//           depth = 1; // Easiest level
//         } else if (gameProvider.gameLevel == 2) {
//           depth = 3; // Medium level
//         } else if (gameProvider.gameLevel == 3) {
//           depth = 5; // Hard level
//         }
//         stockfish.stdin = 'go depth $depth';
//       }
//     }
//
//     await Future.delayed(const Duration(seconds: 1));
//     checkGameOverListener();
//   }
//
//   void letOtherPlayerPlayFirst() {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final gameProvider = context.read<GameProvider>();
//
//       if (gameProvider.vsComputer) {
//         if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
//           gameProvider.setAiThinking(true);
//           await waitUntilReady();
//           stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';
//
//           int depth = 1; // Default depth
//           if (gameProvider.gameLevel == 1) {
//             depth = 1; // Easiest level
//           } else if (gameProvider.gameLevel == 2) {
//             depth = 3; // Medium level
//           } else if (gameProvider.gameLevel == 3) {
//             depth = 5; // Hard level
//           }
//           stockfish.stdin = 'go depth $depth';
//
//           stockfish.stdout.listen((event) {
//             if (event.contains(UCICommands.bestMove)) {
//               final bestMove = event.split(' ')[1];
//               final beforeFen = gameProvider.getPositionFen();
//               gameProvider.makeStringMove(bestMove);
//               final afterFen = gameProvider.getPositionFen();
//
//               // Log before and after FEN
//               print("Before Move FEN: $beforeFen");
//               print("After Move FEN: $afterFen");
//
//               final moveDetails = getMoveDetails(beforeFen, afterFen);
//               print("Stockfish Move Details: ${moveDetails['movedPiece']} ${moveDetails['specialMove']} ${moveDetails['capturedPiece']}");
//
//               updateMoveList(moveDetails.toString(), moveDetails.isNotEmpty);
//               gameProvider.setAiThinking(false);
//               gameProvider.setSquaresState().whenComplete(() {
//                 if (gameProvider.player == Squares.white) {
//                   if (gameProvider.playWhiteTimer) {
//                     gameProvider.pauseBlackTimer();
//                     startTimer(isWhiteTimer: true, onNewGame: () {});
//                     gameProvider.setPlayWhiteTimer(value: false);
//                   }
//                 } else {
//                   if (gameProvider.playBlackTimer) {
//                     gameProvider.pauseWhiteTimer();
//                     startTimer(isWhiteTimer: false, onNewGame: () {});
//                     gameProvider.setPlayBlackTimer(value: false);
//                   }
//                 }
//               });
//               print("moveList: $moveList");
//             }
//           });
//         }
//       } else {
//         final userModel = context.read<AuthenticationProvider>().userModel;
//         gameProvider.listenForGameChanges(context: context, userModel: userModel!);
//       }
//     });
//   }
//
//
//
//   Future<void> waitUntilReady() async {
//     while (stockfish.state.value != StockfishState.ready) {
//       await Future.delayed(const Duration(seconds: 1));
//     }
//   }
//
//   void checkGameOverListener() {
//     final gameProvider = context.read<GameProvider>();
//     gameProvider.gameOverListener(
//       context: context,
//       stockfish: stockfish,
//       onNewGame: () {
//         gameProvider.resetGame(newGame: true);
//       },
//     );
//   }
//
//   void startTimer({
//     required bool isWhiteTimer,
//     required Function onNewGame,
//   }) {
//     final gameProvider = context.read<GameProvider>();
//     if (isWhiteTimer) {
//       // Start timer for white
//       gameProvider.startWhitesTimer(
//         context: context,
//         stockfish: stockfish,
//         onNewGame: onNewGame,
//       );
//     } else {
//       // Start timer for black
//       gameProvider.startBlacksTimer(
//         context: context,
//         stockfish: stockfish,
//         onNewGame: onNewGame,
//       );
//     }
//   }
//
//   CustomPieceSet getPieceSet(bool isLightMode) {
//     String folder = 'assets/images/';
//     return CustomPieceSet.fromSvgAssets(
//       folder: folder,
//       symbols: CustomPieceSet.defaultSymbols,
//       whitePrefix: isLightMode ? 'g' : 'y', // 'g' for light mode, 'w' for dark mode
//       blackPrefix: isLightMode ? 'b' : 'w', // 'y' for light mode, 'b' for dark mode
//     );
//   }
//
//   void switchTheme() {
//     setState(() {
//       isLightMode = !isLightMode;
//     });
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//   Map<String, String> getMoveDetails(String beforeFen, String afterFen) {
//     // Split the FEN strings into parts
//     List<String> beforeParts = beforeFen.split(' ');
//     List<String> afterParts = afterFen.split(' ');
//
//     // The first part of the FEN string is the board representation
//     String beforeBoard = beforeParts[0];
//     String afterBoard = afterParts[0];
//
//     // Function to expand numbers in the FEN string to '1'
//     String expandFenRow(String row) {
//       String expandedRow = '';
//       for (int i = 0; i < row.length; i++) {
//         if (int.tryParse(row[i]) != null) {
//           expandedRow += '1' * int.parse(row[i]);
//         } else {
//           expandedRow += row[i];
//         }
//       }
//       return expandedRow;
//     }
//
//     // Split the board representation into rows and expand them
//     List<String> beforeRows = beforeBoard.split('/').map(expandFenRow).toList();
//     List<String> afterRows = afterBoard.split('/').map(expandFenRow).toList();
//
//     String movedPiece = '';
//     String capturedPiece = '';
//     String specialMove = '';
//
//     // Iterate over the ranks and files to find the move
//     for (int rank = 0; rank < 8; rank++) {
//       for (int file = 0; file < 8; file++) {
//         if (beforeRows[rank][file] != afterRows[rank][file]) {
//           // If before is empty, it means a piece moved to this position
//           if (beforeRows[rank][file] == '1') {
//             movedPiece = getPieceIcon(afterRows[rank][file]);
//           }
//           // If after is empty, it means a piece moved from this position
//           else if (afterRows[rank][file] == '1') {
//             movedPiece = getPieceIcon(beforeRows[rank][file]);
//           }
//           // If both are not empty and different, it's a capture
//           else {
//             movedPiece = getPieceIcon(beforeRows[rank][file]);
//             capturedPiece = getPieceIcon(afterRows[rank][file]);
//           }
//         }
//       }
//     }
//
//     // Set specialMove to "x" if a piece is captured
//     if (capturedPiece.isNotEmpty) {
//       specialMove = 'x';
//     } else {
//       specialMove = '';
//     }
//
//     // Check for castling
//     if (movedPiece == '♔' || movedPiece == '♚') {
//       if (beforeFen.contains('K') && !afterFen.contains('K') && afterFen.contains('g1')) {
//         specialMove = 'O-O';
//       } else if (beforeFen.contains('Q') && !afterFen.contains('Q') && afterFen.contains('c1')) {
//         specialMove = 'O-O-O';
//       } else if (beforeFen.contains('k') && !afterFen.contains('k') && afterFen.contains('g8')) {
//         specialMove = 'O-O';
//       } else if (beforeFen.contains('q') && !afterFen.contains('q') && afterFen.contains('c8')) {
//         specialMove = 'O-O-O';
//       }
//     }
//
//     // Check for checkmate (when the king is missing from the after FEN)
//     if (!afterBoard.contains('K') || !afterBoard.contains('k')) {
//       specialMove = '#'; // checkmate
//     }
//
//     return {
//       'movedPiece': movedPiece,
//       'capturedPiece': capturedPiece,
//       'specialMove': specialMove,
//     };
//   }
//
// // Map for piece icons
//   Map<String, String> pieceIcons = {
//     'K': '♔',
//     'Q': '♕',
//     'R': '♖',
//     'B': '♗',
//     'N': '♘',
//     'P': '♙',
//     'k': '♚',
//     'q': '♛',
//     'r': '♜',
//     'b': '♝',
//     'n': '♞',
//     'p': '♟',
//   };
//
// // Function to get the icon for a piece
//   String getPieceIcon(String piece) {
//     return pieceIcons[piece] ?? piece;
//   }
//
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final gameProvider = context.read<GameProvider>();
//     final userModel = context.read<AuthenticationProvider>().userModel;
//     // gameProvider.resetGame(newGame: false);
//     var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
//     var pieceSet = getPieceSet(isLightMode);
//     final textColor = isLightMode ? Colors.white : Colors.black;
//     if(!gameProvider.vsComputer){
//       gameProvider.listenForOpponentLeave(gameProvider.gameId, context);
//
//     }
//
//     return WillPopScope(
//       onWillPop: () async {
//
//         bool? leave =await _showExitConfirmationDialog(context);
//         if(leave != null && leave){
//           stockfish.stdin = UCICommands.stop;
//         }
//
//         return leave ?? false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.white,),
//             onPressed: () {
//             //   //TODO show diaglog if sure
//             //   Navigator.pop(context);
//             //
//             },
//           ),
//             backgroundColor: const Color(0xFF663d99),
//
//             title: Text('شطرنج القدس',style: TextStyle(color: textColor,fontFamily: 'IBM Plex Sans Arabic',fontWeight: FontWeight.w700),),
//
//             actions: [
//               IconButton(
//                 icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode,),
//                 color: isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
//                 onPressed: switchTheme,
//               ),
//               IconButton(
//                 onPressed: (){
//                   final gameProvider = context.read<GameProvider>();
//                   gameProvider.resetGame(newGame: false);
//                 },
//                 icon: const Icon(Icons.start, color: Colors.white,),
//               ),
//               IconButton(
//                 onPressed:(){
//                   gameProvider.flipTheBoard();
//                 },
//                 icon: const Icon(Icons.rotate_left, color: Colors.white,),
//               ),
//             ]),
//         body: Consumer<GameProvider>(
//           builder: (context,gameProvider,child){
//
//             String whitesTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: true,);
//             String blacksTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: false,);
//             final isGameCreator = gameProvider.gameCreatorUid == userModel!.uid;
//             final opponentUid = isGameCreator ? gameProvider.userId : gameProvider.gameCreatorUid;
//             final opponentName = isGameCreator ? gameProvider.userName : gameProvider.gameCreatorName;
//             final opponentRating = isGameCreator ? gameProvider.userRating : gameProvider.gameCreatorRating;
//
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // opponents data
//                   showOpponentsData(gameProvider: gameProvider, userModel: userModel, timeToShow: blacksTimer,),
//                   gameProvider.vsComputer ?
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: CustomBoardController(
//                       state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
//                       playState: gameProvider.state.state,
//                       pieceSet: pieceSet,
//                       theme: boardTheme,
//                       moves: gameProvider.state.moves,
//                       onMove: _onMove,
//                       onPremove: _onMove,
//                       markerTheme: MarkerTheme(
//                         empty: MarkerTheme.dot,
//                         piece: MarkerTheme.corners(),
//                       ),
//                       promotionBehaviour: PromotionBehaviour.autoPremove,
//                     ),
//                   )
//                   :
//                       buildChessBoard(gameProvider: gameProvider, userModel: userModel),
//
//                   // our data
//                 ListTile(
//                   leading: userModel.image == '' ?
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundImage: AssetImage(AssetsManager.userIcon),
//                   ):
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundImage: NetworkImage(userModel.image ),
//                   ),
//                   title: Text(userModel.name),
//                   subtitle : Text('Rating: $opponentRating }'),
//                   trailing:  Text(
//                     whitesTimer,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                   if (gameProvider.showAnalysisBoard)
//                     Container(
//                       height: 200, // Fixed height for the container
//                       color: Colors.white, // Dark background for the moves list
//                       child: ListView.builder(
//                         itemCount: (moveList.length + 1) ~/ 2,
//                         itemBuilder: (context, index) {
//                           String moveWhite = moveList.length > index * 2 ? moveList[index * 2] : "";
//                           String moveBlack = moveList.length > index * 2 + 1 ? moveList[index * 2 + 1] : "";
//
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   "${index + 1}. $moveWhite",
//                                   style: const TextStyle(color: Colors.black, fontSize: 16),
//                                   textAlign: TextAlign.left,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   moveBlack,
//                                   style: const TextStyle(color: Colors.black, fontSize: 16),
//                                   textAlign: TextAlign.left,
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//
//
//
//
//
//
//                 ],
//               ),
//             );
//
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget buildChessBoard({
//     required GameProvider gameProvider,
//     required UserModel userModel,
//   }) {
//     var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
//     var pieceSet = getPieceSet(isLightMode);
//     bool isOurTurn = gameProvider.isWhitesTurn == (gameProvider.gameCreatorUid == userModel.uid);
//
//
//
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: CustomBoardController(
//         state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
//         playState: isOurTurn ? PlayState.ourTurn : PlayState.theirTurn,
//         pieceSet: pieceSet,
//         theme: boardTheme,
//         moves: gameProvider.state.moves,
//         onMove: _onMove,
//         onPremove: _onMove,
//         markerTheme: MarkerTheme(
//           empty: MarkerTheme.dot,
//           piece: MarkerTheme.corners(),
//         ),
//         promotionBehaviour: PromotionBehaviour.autoPremove,
//       ),
//     );
//
//   }
//
//   getState({required GameProvider gameProvider}){
//     if(gameProvider.flipBoard){
//       return gameProvider.state.board.flipped();
//     }
//     else{
//       gameProvider.state.board;
//     }
//   }
//
//
//   Widget showOpponentsData({
//     required GameProvider gameProvider,
//     required UserModel userModel,
//     required String timeToShow,
//   }) {
//     if(gameProvider.vsComputer){
//       return ListTile(
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundImage: AssetImage(AssetsManager.stockfishIcon),
//         ),
//         title: const Text ('Agent Chess '),
//         subtitle :  Text('Rating:${gameProvider.gameLevel * 1000}'),
//         trailing:  Text(
//           timeToShow,
//           style: const TextStyle(fontSize: 16),),
//       );
//     }
//     else{
//       //check if we are the creator of this game
//       if(gameProvider.gameCreatorUid == userModel.uid){
//         return ListTile(
//           leading: gameProvider.userPhoto == '' ?
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: AssetImage(AssetsManager.userIcon),
//           ):
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: NetworkImage(gameProvider.userPhoto),
//           ),
//           title: Text(gameProvider.userName),
//           subtitle : Text('Rating: ${gameProvider.userRating}'),
//           trailing:  Text(
//             timeToShow,
//             style: const TextStyle(fontSize: 16),
//           ),
//         );
//
//       }
//       else{
//         return ListTile(
//           leading: gameProvider.gameCreatorPhoto == '' ?
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: AssetImage(AssetsManager.userIcon),
//           ):
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
//           ),
//           title: Text(gameProvider.gameCreatorName),
//           subtitle : Text('Rating: ${gameProvider.gameCreatorRating}'),
//           trailing:  Text(
//             timeToShow,
//             style: const TextStyle(fontSize: 16),
//           ),
//         );
//       }
//     }
//   }
//
//   Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
//     final gameProvider = context.read<GameProvider>();
//     final userModel = context.read<AuthenticationProvider>().userModel;
//
//
//     return showDialog<bool>(
//       context: context,
//       builder: (context) =>AlertDialog(
//         title: const Text('Leave Game?',textAlign: TextAlign.center,),
//         content: const Text('Are you sure you want leave this game? ',textAlign: TextAlign.center,),
//         actions: [
//           TextButton(onPressed: (){
//             Navigator.of(context).pop(false);
//           }, child: const Text('Cancel',style: TextStyle(color: Colors.red)),),
//
//           TextButton(onPressed: () async {
//             if(gameProvider.vsComputer){
//               Navigator.of(context).pop(true);
//               // Reset the game when the user confirms to leave
//               context.read<GameProvider>().resetGame(newGame: true);
//             }
//             else{
//               // Use the leaveGame method to handle leaving the game
//               await gameProvider.leaveGame(userModel!.uid);
//               // FirebaseFirestore.instance.collection(Constants.runningGames).doc(gameProvider.gameId).delete();
//
//
//
//               Navigator.of(context).pop(true);
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HomeScreen()),
//                     (Route<dynamic> route) => false,
//               );
//
//             }
//           }, child: const Text('Confirm',),),
//         ],
//       ),);
//
//   }
//   String convertMoveFormat(String move) {
//       // Split the move string into source and destination parts
//       List<String> parts = move.split('-');
//
//       // Ensure there are exactly two parts
//       if (parts.length != 2) {
//         throw const FormatException('Invalid move format');
//       }
//       // Parse the source and destination indices
//       int sourceIndex = int.parse(parts[0]);
//       int destinationIndex = int.parse(parts[1]);
//
//       // Map column index to letter
//       final columnMap = {0: 'a', 1: 'b', 2: 'c', 3: 'd', 4: 'e', 5: 'f', 6: 'g', 7: 'h'};
//
//       // Convert indices to chess notation
//       final sourceColumn = columnMap[sourceIndex % 8];
//       final sourceRow = (8 - (sourceIndex ~/ 8)).toString();
//       final destinationColumn = columnMap[destinationIndex % 8];
//       final destinationRow = (8 - (destinationIndex ~/ 8)).toString();
//
//       // Construct the new move string in chess notation format
//       final newMove = '$sourceColumn$sourceRow-$destinationColumn$destinationRow';
//
//       return newMove;
//
//   }
//   void showPlayerLeftPopup(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Player Left', textAlign: TextAlign.center),
//           content: Text(message, textAlign: TextAlign.center),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

















import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/helper/helper_methods.dart';
import 'package:flutter_chess_1/helper/uci_commands.dart';
import 'package:flutter_chess_1/models/user_model.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:flutter_chess_1/providers/custom_board_controller_provider.dart';
import 'package:flutter_chess_1/service/assests_manager.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';

import '../constants.dart';
import '../providers/custom_board_theme.dart';
import '../providers/custom_piece_set.dart';
import 'home_screen.dart';

bool isLightMode = true;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Stockfish stockfish;
  List<String> moveList = []; // List to store moves

  @override
  void initState() {
    stockfish = Stockfish();
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);
    super.initState();
    if (!gameProvider.vsComputer) {
      gameProvider.listenToGameUpdates();
    }

    if (mounted) {
      letOtherPlayerPlayFirst();
    }

    stockfish.stdout.listen((event) {
      if (event.contains(UCICommands.bestMove)) {
        final bestMove = event.split(' ')[1];
        final newLocation = bestMove.substring(2);
        final beforeFen = gameProvider.getPositionFen();
        gameProvider.makeStringMove(bestMove);
        final afterFen = gameProvider.getPositionFen();

        print("Before Move FEN: $beforeFen");
        print("After Move FEN: $afterFen");

        final moveDetails = getMoveDetails(beforeFen, afterFen);
        print("Stockfish Move Details: ${moveDetails['movedPiece']} ${moveDetails['specialMove']} ${moveDetails['capturedPiece']}");

        gameProvider.setAiThinking(false);
        gameProvider.setSquaresState().whenComplete(() {
          if (gameProvider.player == Squares.white) {
            if (gameProvider.playWhiteTimer) {
              gameProvider.pauseBlackTimer();
              startTimer(
                isWhiteTimer: true,
                onNewGame: () {},
              );

              gameProvider.setPlayWhiteTimer(value: false);
            }
          } else {
            if (gameProvider.playBlackTimer) {
              gameProvider.pauseWhiteTimer();
              startTimer(
                isWhiteTimer: false,
                onNewGame: () {},
              );

              gameProvider.setPlayBlackTimer(value: false);
            }
          }
        });
        updateMoveList(moveDetails, newLocation);
        print('moveList: $moveList');
      }
    });
  }
  @override
  void dispose() {
    stockfish.dispose();
    super.dispose();
  }

  bool isValidMove(String move) {
    // Ensure the move matches the chess notation format like "e2-e4"
    final moveRegExp = RegExp(r'^[a-h][1-8][a-h][1-8]$');
    return moveRegExp.hasMatch(move);
  }

  void updateMoveList(Map<String, String> moveDetails, String move) {
    final formattedMove = formatMoveDetails(moveDetails, move);
    setState(() {
      moveList.add(formattedMove);
    });
  }



  void letOtherPlayerPlayFirst() {
    // Wait for widget to rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = context.read<GameProvider>();

      if (gameProvider.vsComputer) {
        if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
          gameProvider.setAiThinking(true);

          // Wait until stockfish is ready
          await waitUntilReady();

          // Get the current position of the board and send it to stockfish
          stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';

          // Set stockfish level
          stockfish.stdin = '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';
        }
      } else {
        final userModel = context.read<AuthenticationProvider>().userModel;
        // Listen for firestore changes
        gameProvider.listenForGameChanges(
          context: context,
          userModel: userModel!,
        );
      }
    });
  }

  void _onMove(Move move) async {
    final gameProvider = context.read<GameProvider>();
    final beforeFen = gameProvider.getPositionFen();
    bool result = gameProvider.makeSquaresMove(move);
    final afterFen = gameProvider.getPositionFen();

    print("Before Move FEN: $beforeFen");
    print("After Move FEN: $afterFen");

    final moveDetails = getMoveDetails(beforeFen, afterFen);
    print("Human Move Details: ${moveDetails['movedPiece']} ${moveDetails['specialMove']} ${moveDetails['capturedPiece']}");

    final newMove = convertMoveFormat(move.toString()).split('-')[1];

    if (result) {
      gameProvider.setSquaresState().whenComplete(() async {
        if (gameProvider.player == Squares.white) {
          if (gameProvider.vsComputer) {
            gameProvider.pauseWhiteTimer();
            startTimer(
              isWhiteTimer: false,
              onNewGame: () {},
            );
            gameProvider.setPlayWhiteTimer(value: true);
          } else {
            print("move gs white: $move");
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: true,
              beforeFen: beforeFen,
              afterFen: afterFen,
            );
          }
          updateMoveList(moveDetails, newMove);
        } else {
          if (gameProvider.vsComputer) {
            gameProvider.pauseBlackTimer();
            startTimer(
              isWhiteTimer: true,
              onNewGame: () {},
            );
            gameProvider.setPlayBlackTimer(value: true);
          } else {
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: false,
              beforeFen: beforeFen,
              afterFen: afterFen,
            );
          }
          updateMoveList(moveDetails, newMove);
        }
        print('moves: $moveList');
      });
    }

    if (gameProvider.vsComputer) {
      if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
        gameProvider.setAiThinking(true);

        await waitUntilReady();

        stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';

        stockfish.stdin = '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    checkGameOverListener();
  }





  Future<void> waitUntilReady() async {
    while (stockfish.state.value != StockfishState.ready) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void checkGameOverListener() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.gameOverListener(
      context: context,
      stockfish: stockfish,
      onNewGame: () {
        gameProvider.resetGame(newGame: true);
      },
    );
  }

  void startTimer({
    required bool isWhiteTimer,
    required Function onNewGame,
  }) {
    final gameProvider = context.read<GameProvider>();
    if (isWhiteTimer) {
      // Start timer for white
      gameProvider.startWhitesTimer(
        context: context,
        stockfish: stockfish,
        onNewGame: onNewGame,
      );
    } else {
      // Start timer for black
      gameProvider.startBlacksTimer(
        context: context,
        stockfish: stockfish,
        onNewGame: onNewGame,
      );
    }
  }

  CustomPieceSet getPieceSet(bool isLightMode) {
    String folder = 'assets/images/';
    return CustomPieceSet.fromSvgAssets(
      folder: folder,
      symbols: CustomPieceSet.defaultSymbols,
      whitePrefix: isLightMode ? 'g' : 'y', // 'g' for light mode, 'w' for dark mode
      blackPrefix: isLightMode ? 'b' : 'w', // 'y' for light mode, 'b' for dark mode
    );
  }

  void switchTheme() {
    setState(() {
      isLightMode = !isLightMode;
    });
  }

  Map<String, String> getMoveDetails(String beforeFen, String afterFen) {
    List<String> beforeParts = beforeFen.split(' ');
    List<String> afterParts = afterFen.split(' ');

    String beforeBoard = beforeParts[0];
    String afterBoard = afterParts[0];

    String expandFenRow(String row) {
      String expandedRow = '';
      for (int i = 0; i < row.length; i++) {
        if (int.tryParse(row[i]) != null) {
          expandedRow += '1' * int.parse(row[i]);
        } else {
          expandedRow += row[i];
        }
      }
      return expandedRow;
    }

    List<String> beforeRows = beforeBoard.split('/').map(expandFenRow).toList();
    List<String> afterRows = afterBoard.split('/').map(expandFenRow).toList();

    String movedPiece = '';
    String capturedPiece = '';
    String specialMove = '';

    for (int rank = 0; rank < 8; rank++) {
      for (int file = 0; file < 8; file++) {
        if (beforeRows[rank][file] != afterRows[rank][file]) {
          // Piece moved to this position
          if (beforeRows[rank][file] == '1' && afterRows[rank][file] != '1') {
            movedPiece = getPieceIcon(afterRows[rank][file]);
          }
          // Piece moved from this position
          else if (beforeRows[rank][file] != '1' && afterRows[rank][file] == '1') {
            // No need to assign capturedPiece here
          }
          // Capture detected
          else if (beforeRows[rank][file] != '1' && afterRows[rank][file] != '1') {
            movedPiece = getPieceIcon(beforeRows[rank][file]);
            capturedPiece = getPieceIcon(afterRows[rank][file]);
          }
        }
      }
    }

    if (capturedPiece.isNotEmpty) {
      specialMove = 'x';
    }

    if (movedPiece == '♔' || movedPiece == '♚') {
      if (beforeFen.contains('K') && !afterFen.contains('K') && afterFen.contains('g1')) {
        specialMove = 'O-O';
      } else if (beforeFen.contains('Q') && !afterFen.contains('Q') && afterFen.contains('c1')) {
        specialMove = 'O-O-O';
      } else if (beforeFen.contains('k') && !afterFen.contains('k') && afterFen.contains('g8')) {
        specialMove = 'O-O';
      } else if (beforeFen.contains('q') && !afterFen.contains('q') && afterFen.contains('c8')) {
        specialMove = 'O-O-O';
      }
    }

    if (!afterBoard.contains('K') || !afterBoard.contains('k')) {
      specialMove = '#';
    }

    return {
      'movedPiece': movedPiece,
      'capturedPiece': capturedPiece,
      'specialMove': specialMove,
    };
  }





  String formatMoveDetails(Map<String, String> moveDetails, String move) {
    final piece = moveDetails['movedPiece'] ?? '';
    final specialMove = moveDetails['specialMove'] ?? '';
    final capturedPiece = moveDetails['capturedPiece'] ?? '';

    if (specialMove == 'x' && capturedPiece.isNotEmpty) {
      return '$capturedPiece$specialMove$move';
    } else if (specialMove == 'O-O' || specialMove == 'O-O-O' || specialMove == '#') {
      return '$piece$specialMove';
    } else if (specialMove == '+') {
      return '$piece$move$specialMove';
    } else {
      return '$piece$move';
    }
  }








  // Map for piece icons
  Map<String, String> pieceIcons = {
    'K': '♔',
    'Q': '♕',
    'R': '♖',
    'B': '♗',
    'N': '♘',
    'P': '♙',
    'k': '♚',
    'q': '♛',
    'r': '♜',
    'b': '♝',
    'n': '♞',
    'p': '♟︎',
  };

  // Function to get the icon for a piece
  String getPieceIcon(String piece) {
    return pieceIcons[piece] ?? piece;
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final userModel = context.read<AuthenticationProvider>().userModel;
    // gameProvider.resetGame(newGame: false);
    var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
    var pieceSet = getPieceSet(isLightMode);
    final textColor = isLightMode ? Colors.white : Colors.black;
    final oppColor = isLightMode ? Colors.black : Colors.white;


    if (!gameProvider.vsComputer) {
      gameProvider.listenForOpponentLeave(gameProvider.gameId, context);
    }

    return WillPopScope(
      onWillPop: () async {
        bool? leave = await _showExitConfirmationDialog(context);
        if (leave != null && leave) {
          stockfish.stdin = UCICommands.stop;
        }

        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              bool? leave = await _showExitConfirmationDialog(context);
              if (leave != null && leave) {
                stockfish.stdin = UCICommands.stop;
                Navigator.of(context).pop(true);
              }
            },
          ),

          backgroundColor: const Color(0xFF663d99),
          title: const Text(
            'شطرنج القدس',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode),
              color: isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
              onPressed: (){},
            ),
            IconButton(
              // onPressed: () {
              //   final gameProvider = context.read<GameProvider>();
              //   gameProvider.resetGame(newGame: false);
              // },
              icon: Icon(Icons.invert_colors, color: isLightMode ? const Color(0xfff0f5f7) :  const Color(0xfff0c230)),
              onPressed: switchTheme,
            ),
            IconButton(
              onPressed: () {
                gameProvider.flipTheBoard();
              },
              icon: const Icon(Icons.rotate_left, color: Colors.white),
            ),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            String whitesTimer = getTimerToDisplay(
              gameProvider: gameProvider,
              isUser: true,
            );
            String blacksTimer = getTimerToDisplay(
              gameProvider: gameProvider,
              isUser: false,
            );
            final isGameCreator = gameProvider.gameCreatorUid == userModel!.uid;
            final opponentUid = isGameCreator ? gameProvider.userId : gameProvider.gameCreatorUid;
            final opponentName = isGameCreator ? gameProvider.userName : gameProvider.gameCreatorName;
            final opponentRating = isGameCreator ? gameProvider.userRating : gameProvider.gameCreatorRating;


            // return SingleChildScrollView(
            //   child: Column(
            //     children: [
            //       // opponents data
            //       showOpponentsData(
            //         gameProvider: gameProvider,
            //         userModel: userModel,
            //         timeToShow: blacksTimer,
            //       ),
            //       gameProvider.vsComputer
            //           ? Padding(
            //         padding: const EdgeInsets.all(4.0),
            //         child: CustomBoardController(
            //           state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
            //           playState: gameProvider.state.state,
            //           pieceSet: pieceSet,
            //           theme: boardTheme,
            //           moves: gameProvider.state.moves,
            //           onMove: _onMove,
            //           onPremove: _onMove,
            //           markerTheme: MarkerTheme(
            //             empty: MarkerTheme.dot,
            //             piece: MarkerTheme.corners(),
            //           ),
            //           promotionBehaviour: PromotionBehaviour.autoPremove,
            //         ),
            //       )
            //           : buildChessBoard(gameProvider: gameProvider, userModel: userModel),
            //
            //       // our data
            //       ListTile(
            //         leading: userModel.image == ''
            //             ? CircleAvatar(
            //           radius: 25,
            //           backgroundImage: AssetImage(AssetsManager.userIcon),
            //         )
            //             : CircleAvatar(
            //           radius: 25,
            //           backgroundImage: NetworkImage(userModel.image),
            //         ),
            //         title: Text(userModel.name),
            //         subtitle: Text('Rating: $opponentRating }'),
            //         trailing: Text(
            //           whitesTimer,
            //           style: const TextStyle(fontSize: 16),
            //         ),
            //       ),
            //       if (gameProvider.showAnalysisBoard)
            //         Container(
            //           height: 200, // Fixed height for the container
            //           color: Colors.white, // Dark background for the moves list
            //           child: ListView.builder(
            //             itemCount: (moveList.length + 1) ~/ 2,
            //             itemBuilder: (context, index) {
            //               String moveWhite = moveList.length > index * 2 ? moveList[index * 2] : "";
            //               String moveBlack = moveList.length > index * 2 + 1 ? moveList[index * 2 + 1] : "";
            //
            //               return Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                 children: [
            //                   Expanded(
            //                     child: Text(
            //                       "${index + 1}. $moveWhite",
            //                       style: TextStyle(color: oppColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700,fontSize: 22),
            //                       textAlign: TextAlign.left,
            //                     ),
            //                   ),
            //                   Expanded(
            //                     child: Text(
            //                       moveBlack,
            //                       style: TextStyle(color: oppColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700,fontSize: 22),
            //                       textAlign: TextAlign.left,
            //                     ),
            //                   ),
            //                 ],
            //               );
            //             },
            //           ),
            //         ),
            //     ],
            //   ),
            // );
            return SingleChildScrollView(
              child: Column(
                children: [
                  // opponents data
                  showOpponentsData(
                    gameProvider: gameProvider,
                    userModel: userModel,
                    timeToShow: blacksTimer,
                  ),
                  gameProvider.vsComputer
                      ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomBoardController(
                      state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
                      playState: gameProvider.state.state,
                      pieceSet: pieceSet,
                      theme: boardTheme,
                      moves: gameProvider.state.moves,
                      onMove: _onMove,
                      onPremove: _onMove,
                      markerTheme: MarkerTheme(
                        empty: MarkerTheme.dot,
                        piece: MarkerTheme.corners(),
                      ),
                      promotionBehaviour: PromotionBehaviour.autoPremove,
                    ),
                  )
                      : buildChessBoard(gameProvider: gameProvider, userModel: userModel),

                  // our data
                  ListTile(
                    leading: userModel.image == ''
                        ? CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(AssetsManager.userIcon),
                    )
                        : CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(userModel.image),
                    ),
                    title: Text(userModel.name),
                    subtitle: Text('Rating: $opponentRating }'),
                    trailing: Text(
                      whitesTimer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (gameProvider.showAnalysisBoard)
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          border: TableBorder.all(color: const Color(0xff4e3c96), width: 3),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(4),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      userModel.name,
                                      style: TextStyle(
                                        color: oppColor,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Agent Chess',
                                      style: TextStyle(
                                        color: oppColor,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...List<TableRow>.generate(
                              (moveList.length + 1) ~/ 2,
                                  (index) {
                                String moveWhite = moveList.length > index * 2 ? moveList[index * 2] : "";
                                String moveBlack = moveList.length > index * 2 + 1 ? moveList[index * 2 + 1] : "";

                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${index + 1}. $moveWhite",
                                          style: TextStyle(
                                            color: oppColor,
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          moveBlack,
                                          style: TextStyle(
                                            color: oppColor,
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildChessBoard({
    required GameProvider gameProvider,
    required UserModel userModel,
  }) {
    var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
    var pieceSet = getPieceSet(isLightMode);
    bool isOurTurn = gameProvider.isWhitesTurn == (gameProvider.gameCreatorUid == userModel.uid);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CustomBoardController(
        state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
        playState: isOurTurn ? PlayState.ourTurn : PlayState.theirTurn,
        pieceSet: pieceSet,
        theme: boardTheme,
        moves: gameProvider.state.moves,
        onMove: _onMove,
        onPremove: _onMove,
        markerTheme: MarkerTheme(
          empty: MarkerTheme.dot,
          piece: MarkerTheme.corners(),
        ),
        promotionBehaviour: PromotionBehaviour.autoPremove,
      ),
    );
  }

  getState({required GameProvider gameProvider}) {
    if (gameProvider.flipBoard) {
      return gameProvider.state.board.flipped();
    } else {
      gameProvider.state.board;
    }
  }

  Widget showOpponentsData({
    required GameProvider gameProvider,
    required UserModel userModel,
    required String timeToShow,
  }) {
    if (gameProvider.vsComputer) {
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.stockfishIcon),
        ),
        title: const Text('Agent Chess '),
        subtitle: Text('Rating:${gameProvider.gameLevel * 1000}'),
        trailing: Text(
          timeToShow,
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      //check if we are the creator of this game
      if (gameProvider.gameCreatorUid == userModel.uid) {
        return ListTile(
          leading: gameProvider.userPhoto == ''
              ? CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          )
              : CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.userPhoto),
          ),
          title: Text(gameProvider.userName),
          subtitle: Text('Rating: ${gameProvider.userRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 16),
          ),
        );
      } else {
        return ListTile(
          leading: gameProvider.gameCreatorPhoto == ''
              ? CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          )
              : CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
          ),
          title: Text(gameProvider.gameCreatorName),
          subtitle: Text('Rating: ${gameProvider.gameCreatorRating}'),
          trailing: Text(
            timeToShow,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }
    }
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    final gameProvider = context.read<GameProvider>();
    final userModel = context.read<AuthenticationProvider>().userModel;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game?', textAlign: TextAlign.center),
        content: const Text('Are you sure you want leave this game? ', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              if (gameProvider.vsComputer) {
                Navigator.of(context).pop(true);
                // Reset the game when the user confirms to leave
                context.read<GameProvider>().resetGame(newGame: true);
              } else {
                // Use the leaveGame method to handle leaving the game
                await gameProvider.leaveGame(userModel!.uid);
                // FirebaseFirestore.instance.collection(Constants.runningGames).doc(gameProvider.gameId).delete();

                Navigator.of(context).pop(true);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String convertMoveFormat(String move) {
    // Split the move string into source and destination parts
    List<String> parts = move.split('-');

    // Ensure there are exactly two parts
    if (parts.length != 2) {
      throw const FormatException('Invalid move format');
    }
    // Parse the source and destination indices
    int sourceIndex = int.parse(parts[0]);
    int destinationIndex = int.parse(parts[1]);

    // Map column index to letter
    final columnMap = {0: 'a', 1: 'b', 2: 'c', 3: 'd', 4: 'e', 5: 'f', 6: 'g', 7: 'h'};

    // Convert indices to chess notation
    final sourceColumn = columnMap[sourceIndex % 8];
    final sourceRow = (8 - (sourceIndex ~/ 8)).toString();
    final destinationColumn = columnMap[destinationIndex % 8];
    final destinationRow = (8 - (destinationIndex ~/ 8)).toString();

    // Construct the new move string in chess notation format
    final newMove = '$sourceColumn$sourceRow-$destinationColumn$destinationRow';

    return newMove;
  }

  void showPlayerLeftPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Player Left', textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
