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
        print("best move 1:$bestMove");
        gameProvider.makeStringMove(bestMove);
        gameProvider.setAiThinking(false);
        gameProvider.setSquaresState().whenComplete(() {
          if (gameProvider.player == Squares.white) {
            // Check if we can play white's timer
            if (gameProvider.playWhiteTimer) {
              // Pause timer for black
              gameProvider.pauseBlackTimer();
              startTimer(
                isWhiteTimer: true,
                onNewGame: () {},
              );

              gameProvider.setPlayWhiteTimer(value: false);
            }
          } else {
            if (gameProvider.playBlackTimer) {
              // Pause timer for white
              gameProvider.pauseWhiteTimer();
              startTimer(
                isWhiteTimer: false,
                onNewGame: () {},
              );

              gameProvider.setPlayBlackTimer(value: false);
            }
          }
        });
        updateMoveList(newLocation);
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
    final moveRegExp = RegExp(r'^[a-h][1-8]-[a-h][1-8]$');
    return moveRegExp.hasMatch(move);
  }

  // Function to update move list
  void updateMoveList(String move) {
    // Add the current move to the moves list
    if (isValidMove(move)) {
      setState(() {
        moveList.add(move);
      });
    }
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

          stockfish.stdout.listen((event) {
            if (event.contains(UCICommands.bestMove)) {
              final bestMove = event.split(' ')[1];
              gameProvider.makeStringMove(bestMove);
              gameProvider.setAiThinking(false);
              gameProvider.setSquaresState().whenComplete(() {
                if (gameProvider.player == Squares.white) {
                  // Check if we can play white's timer
                  if (gameProvider.playWhiteTimer) {
                    // Pause timer for black
                    gameProvider.pauseBlackTimer();
                    startTimer(
                      isWhiteTimer: true,
                      onNewGame: () {},
                    );

                    gameProvider.setPlayWhiteTimer(value: false);
                  }
                } else {
                  if (gameProvider.playBlackTimer) {
                    // Pause timer for white
                    gameProvider.pauseWhiteTimer();
                    startTimer(
                      isWhiteTimer: false,
                      onNewGame: () {},
                    );

                    gameProvider.setPlayBlackTimer(value: false);
                  }
                }
              });
            }
          });
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
    print("move before convert 1 : $move");

    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.makeSquaresMove(move);
    print("move before convert2: $move");
    final newMove = convertMoveFormat(move.toString()).split('-')[1];
    if (result) {
      gameProvider.setSquaresState().whenComplete(() async {
        if (gameProvider.player == Squares.white) {
          // Check if we are playing vs computer
          if (gameProvider.vsComputer) {
            // Pause timer for white
            gameProvider.pauseWhiteTimer();
            startTimer(
              isWhiteTimer: false,
              onNewGame: () {},
            );
            // Set white bool flag to true so we don't run the code again until true
            gameProvider.setPlayWhiteTimer(value: true);
          } else {
            // Play and save whites move to firestore
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: true,
            );
            updateMoveList(newMove);
          }
        } else {
          if (gameProvider.vsComputer) {
            // Pause timer for black
            gameProvider.pauseBlackTimer();
            startTimer(
              isWhiteTimer: true,
              onNewGame: () {},
            );
            // Set black bool flag to true so we don't run the code again until true
            gameProvider.setPlayBlackTimer(value: true);
          } else {
            // Play and save black's move to firestore
            await gameProvider.playMoveAndSaveToFirestore(
              context: context,
              move: move,
              isWhitesMove: false,
            );
            updateMoveList(newMove);
          }
        }
        print('moves: $moveList');
      });
    }
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
    }

    await Future.delayed(const Duration(seconds: 1));
    // Check if the game's over
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

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final userModel = context.read<AuthenticationProvider>().userModel;
    // gameProvider.resetGame(newGame: false);
    var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
    var pieceSet = getPieceSet(isLightMode);
    final textColor = isLightMode ? Colors.white : Colors.black;
    if(!gameProvider.vsComputer){
      gameProvider.listenForOpponentLeave(gameProvider.gameId, context);

    }

    return WillPopScope(
      onWillPop: () async {

        bool? leave =await _showExitConfirmationDialog(context);
        if(leave != null && leave){
          stockfish.stdin = UCICommands.stop;
        }

        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () async {
              bool? leave = await _showExitConfirmationDialog(context);
              if (leave != null && leave) {
                stockfish.stdin = UCICommands.stop;
                Navigator.of(context).pop(true);
              }
            },
          ),
            backgroundColor: const Color(0xFF663d99),

            title: Text('شطرنج القدس',style: TextStyle(color: textColor,fontFamily: 'IBM Plex Sans Arabic',fontWeight: FontWeight.w700),),

            actions: [
              IconButton(
                icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode,),
                color: isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
                onPressed: switchTheme,
              ),
              IconButton(
                onPressed: (){
                  final gameProvider = context.read<GameProvider>();
                  gameProvider.resetGame(newGame: false);
                },
                icon: const Icon(Icons.start, color: Colors.white,),
              ),
              IconButton(
                onPressed:(){
                  gameProvider.flipTheBoard();
                },
                icon: const Icon(Icons.rotate_left, color: Colors.white,),
              ),
            ]),
        body: Consumer<GameProvider>(
          builder: (context,gameProvider,child){

            String whitesTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: true,);
            String blacksTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: false,);
            final isGameCreator = gameProvider.gameCreatorUid == userModel!.uid;
            final opponentUid = isGameCreator ? gameProvider.userId : gameProvider.gameCreatorUid;
            final opponentName = isGameCreator ? gameProvider.userName : gameProvider.gameCreatorName;
            final opponentRating = isGameCreator ? gameProvider.userRating : gameProvider.gameCreatorRating;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // opponents data
                  showOpponentsData(gameProvider: gameProvider, userModel: userModel, timeToShow: blacksTimer,),
                  gameProvider.vsComputer ?
                  Padding(
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
                  :
                      buildChessBoard(gameProvider: gameProvider, userModel: userModel),

                  // our data
                ListTile(
                  leading: userModel.image == '' ?
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(AssetsManager.userIcon),
                  ):
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userModel.image ),
                  ),
                  title: Text(userModel.name),
                  subtitle : Text('Rating: $opponentRating }'),
                  trailing:  Text(
                    whitesTimer,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                  if (gameProvider.showAnalysisBoard)
                    Container(
                      height: 200, // Fixed height for the container
                      color: Colors.white, // Dark background for the moves list
                      child: ListView.builder(
                        itemCount: (moveList.length + 1) ~/ 2,
                        itemBuilder: (context, index) {
                          String moveWhite = moveList.length > index * 2 ? moveList[index * 2] : "";
                          String moveBlack = moveList.length > index * 2 + 1 ? moveList[index * 2 + 1] : "";

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Text(
                                  "${index + 1}. $moveWhite",
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  moveBlack,
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          );
                        },
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

  getState({required GameProvider gameProvider}){
    if(gameProvider.flipBoard){
      return gameProvider.state.board.flipped();
    }
    else{
      gameProvider.state.board;
    }
  }


  Widget showOpponentsData({
    required GameProvider gameProvider,
    required UserModel userModel,
    required String timeToShow,
  }) {
    if(gameProvider.vsComputer){
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.stockfishIcon),
        ),
        title: const Text ('Agent Chess '),
        subtitle :  Text('Rating:${gameProvider.gameLevel * 1000}'),
        trailing:  Text(
          timeToShow,
          style: const TextStyle(fontSize: 16),),
      );
    }
    else{
      //check if we are the creator of this game
      if(gameProvider.gameCreatorUid == userModel.uid){
        return ListTile(
          leading: gameProvider.userPhoto == '' ?
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          ):
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.userPhoto),
          ),
          title: Text(gameProvider.userName),
          subtitle : Text('Rating: ${gameProvider.userRating}'),
          trailing:  Text(
            timeToShow,
            style: const TextStyle(fontSize: 16),
          ),
        );

      }
      else{
        return ListTile(
          leading: gameProvider.gameCreatorPhoto == '' ?
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          ):
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
          ),
          title: Text(gameProvider.gameCreatorName),
          subtitle : Text('Rating: ${gameProvider.gameCreatorRating}'),
          trailing:  Text(
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
      builder: (context) =>AlertDialog(
        title: const Text('Leave Game?',textAlign: TextAlign.center,),
        content: const Text('Are you sure you want leave this game? ',textAlign: TextAlign.center,),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop(false);
          }, child: const Text('Cancel',style: TextStyle(color: Colors.red)),),

          TextButton(onPressed: () async {
            if(gameProvider.vsComputer){
              Navigator.of(context).pop(true);
              // Reset the game when the user confirms to leave
              context.read<GameProvider>().resetGame(newGame: true);
            }
            else{
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
          }, child: const Text('Confirm',),),
        ],
      ),);

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