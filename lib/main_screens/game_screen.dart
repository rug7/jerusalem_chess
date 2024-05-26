import 'package:flutter/material.dart';
import 'package:flutter_chess_1/helper/helper_methods.dart';
import 'package:flutter_chess_1/helper/uci_commands.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:flutter_chess_1/providers/custom_board_controller_provider.dart';
import 'package:flutter_chess_1/service/assests_manager.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';

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
  List<String> moves = [];
  @override
  void initState() {
    stockfish = Stockfish();
    final gameProvider =  context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);

    if(mounted){
      letOtherPlayerPlayFirst();
    }
    super.initState();
  }
  @override
  void dispose(){
    stockfish.dispose();
    super.dispose();
  }

  void letOtherPlayerPlayFirst(){
    //wait for widget to rebuild
    WidgetsBinding.instance.addPostFrameCallback((_)async {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
        gameProvider.setAiThinking(true);

        //wait until stockfish is ready
        await waitUntilReady();

        //get the current position of the board and send it to stockfish
        stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';

        //set stockfish level
        stockfish.stdin = '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

        stockfish.stdout.listen((event) {
          if(event.contains(UCICommands.bestMove)){
            final bestMove = event.split(' ')[1];
            gameProvider.makeStringMove(bestMove);
            gameProvider.setAiThinking(false);
            gameProvider.setSquaresState().whenComplete(() {
              if(gameProvider.player == Squares.white){
                //check if we can play white's timer
                if(gameProvider.playWhiteTimer){
                  //pause timer for black
                  gameProvider.pauseBlackTimer();
                  startTimer(
                    isWhiteTimer: true,
                    onNewGame: (){},
                  );

                  gameProvider.setPlayWhiteTimer(value: false);
                }
              }
              else{

                if(gameProvider.playBlackTimer){
                  //pause timer for white
                  gameProvider.pauseWhiteTimer();
                  startTimer(
                    isWhiteTimer: false,
                    onNewGame: (){},
                  );

                  gameProvider.setPlayBlackTimer(value: false);
                }
              }
            });

          }
        });

      }

    });
  }

  void _onMove(Move move) async {
    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.makeSquaresMove(move);
    if (result) {
      gameProvider.setSquaresState().whenComplete(() {
        if(gameProvider.player == Squares.white){
          //pause timer for white
          gameProvider.pauseWhiteTimer();
          startTimer(
            isWhiteTimer: false,
            onNewGame: (){},
          );
          //set white bool flag to true so we don't run the code again until true
          gameProvider.setPlayWhiteTimer(value: true);
        } else{
          //pause timer for black
          gameProvider.pauseBlackTimer();
          startTimer(
            isWhiteTimer: true,
            onNewGame: (){},
          );
          //set black bool flag to true so we don't run the code again until true

          gameProvider.setPlayBlackTimer(value: true);
        }

      });
    }
    if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
      gameProvider.setAiThinking(true);

      //wait until stockfish is ready
      await waitUntilReady();

      //get the current position of the board and send it to stockfish
      stockfish.stdin = '${UCICommands.position} ${gameProvider.getPositionFen()}';

      //set stockfish level
      stockfish.stdin = '${UCICommands.goMoveTime} ${gameProvider.gameLevel * 1000}';

      stockfish.stdout.listen((event) {
        if(event.contains(UCICommands.bestMove)){
          final bestMove = event.split(' ')[1];
          gameProvider.makeStringMove(bestMove);
          gameProvider.setAiThinking(false);
          gameProvider.setSquaresState().whenComplete(() {
            if(gameProvider.player == Squares.white){
              //check if we can play white's timer
              if(gameProvider.playWhiteTimer){
                //pause timer for black
                gameProvider.pauseBlackTimer();
                startTimer(
                  isWhiteTimer: true,
                  onNewGame: (){},
                );

                gameProvider.setPlayWhiteTimer(value: false);
              }
            }
            else{

              if(gameProvider.playBlackTimer){
                //pause timer for white
                gameProvider.pauseWhiteTimer();
                startTimer(
                  isWhiteTimer: false,
                  onNewGame: (){},
                );

                gameProvider.setPlayBlackTimer(value: false);
              }
            }
          });

        }
      });


      // await Future.delayed(
      //     Duration(milliseconds: Random().nextInt(4750) + 250));
      // gameProvider.game.makeRandomMove();
      // gameProvider.setAiThinking(false);
      // gameProvider.setSquaresState().whenComplete(() {
      //   if(gameProvider.player == Squares.white){
      //     //pause timer for black
      //     gameProvider.pauseBlackTimer();
      //     startTimer(
      //       isWhiteTimer: true,
      //       onNewGame: (){},
      //     );
      //
      //   }
      //   else{
      //     //pause timer for white
      //     gameProvider.pauseWhiteTimer();
      //     startTimer(
      //       isWhiteTimer: false,
      //       onNewGame: (){},
      //     );
      //   }
      // });
    }

    await Future.delayed(const Duration(seconds: 1));
    //check if the game's over
    checkGameOverListener();
  }

  Future<void>waitUntilReady()async{
    while(stockfish.state.value != StockfishState.ready){
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void checkGameOverListener(){
    final gameProvider =  context.read<GameProvider>();
    gameProvider.gameOverListener(
      context: context,
      stockfish:stockfish,
      onNewGame:(){
        gameProvider.resetGame(newGame: true);
      },
    );
  }

  void startTimer({
    required bool isWhiteTimer,
    required Function onNewGame,
  }){
    final gameProvider = context.read<GameProvider>();
    if(isWhiteTimer){
      //start timer for white
      gameProvider.startWhitesTimer(
          context: context,
          stockfish: stockfish,
          onNewGame: onNewGame
      );
    }
    else{
      //start timer for black
      gameProvider.startBlacksTimer(
          context: context,
          stockfish: stockfish,
          onNewGame: onNewGame
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
    // gameProvider.resetGame(newGame: false);
    var boardTheme = isLightMode ? CustomBoardTheme.goldPurple : CustomBoardTheme.blackGrey;
    var pieceSet = getPieceSet(isLightMode);
    final textColor = isLightMode ? Colors.white : Colors.black;

    return WillPopScope(
      onWillPop: () async {

       bool? leave =await _showExitConfirmationDialog(context);
       if(leave != null && leave){
         stockfish.stdin = UCICommands.stop;
         Navigator.pushAndRemoveUntil(
           context,
           MaterialPageRoute(builder: (context) => const HomeScreen()),
               (Route<dynamic> route) => false,// Ensure you import HomeScreen if not already imported
         );
       }

        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
            // leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.white,),
            //   onPressed: () {
            //     //TODO show diaglog if sure
            //     Navigator.pop(context);
            //
            //   },
            // ),
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

            return SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // opponents data
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(AssetsManager.stockfishIcon),
                    ),
                    title: const Text (''),
                    subtitle : const Text('Rating: 3000'),
                    trailing:  Text(
                      blacksTimer,
                      style: const TextStyle(fontSize: 16),),
                  ),
              
              
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
                  ),
              
                  // our data
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(AssetsManager.userIcon),
                    ),
                    title: const Text('ME'),
                    subtitle : const Text('Rating: 1200'),
                    trailing:  Text(
                      whitesTimer,
                      style: const TextStyle(fontSize: 16),
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

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {

    return showDialog<bool>(
        context: context,
        builder: (context) =>AlertDialog(
          title: const Text('Leave Game?',textAlign: TextAlign.center,),
          content: const Text('Are you sure you want leave this game? ',textAlign: TextAlign.center,),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop(false);
            }, child: const Text('Cancel',style: TextStyle(color: Colors.red)),),

            TextButton(onPressed: (){
              Navigator.of(context).pop(true);
              // Reset the game when the user confirms to leave
              context.read<GameProvider>().resetGame(newGame: true);
            }, child: const Text('Confirm',),),
          ],
        ),);

  }

}

