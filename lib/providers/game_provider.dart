import 'dart:async';

import 'package:bishop/bishop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/helper/uci_commands.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';

class GameProvider extends ChangeNotifier{
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  bool _playWhiteTimer = true;
  bool _playBlackTimer = true;

  int _gameLevel = 1;
  int _player = Squares.white;
  Timer? _whiteTimer;
  Timer? _blackTimer;
  int _whiteScore = 0;
  int _blackScore = 0;
  int _incrementalValue = 0;
  //TODO check stockfish
  PlayerColor _playerColor = PlayerColor.white;
  GameDifficulty _gameDifficulty = GameDifficulty.easy;

  Duration _whiteTime = Duration.zero;
  Duration _blackTime = Duration.zero;

  //save the time
  Duration _whiteSavedTime = Duration.zero;
  Duration _blackSavedTime = Duration.zero;

  bool get playWhiteTimer => _playWhiteTimer;
  bool get playBlackTimer => _playBlackTimer;

  Timer? get whiteTimer => _whiteTimer;
  Timer? get blackTimer => _blackTimer;

  int get whiteScore => _whiteScore;
  int get blackScore => _blackScore;

  bishop.Game get game => _game;
  SquaresState get state => _state;
  bool get aiThinking => _aiThinking;
  bool get flipBoard => _flipBoard;

  int get gameLevel => _gameLevel;
  GameDifficulty get gameDifficulty => _gameDifficulty;
  int get incrementalValue => _incrementalValue;

  int get player => _player;
  PlayerColor get playerColor => _playerColor;

  Duration get whiteTime => _whiteTime;
  Duration get blackTime => _blackTime;

  Duration get whiteSavedTime => _whiteSavedTime;
  Duration get blackSavedTime => _blackSavedTime;

  //get method
  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;


  //set play White's Timer
  Future<void>setPlayWhiteTimer({required bool value}) async {
    _playWhiteTimer = value;
    notifyListeners();
  }

  //set play Black's Timer
  Future<void>setPlayBlackTimer({required bool value}) async {
    _playBlackTimer = value;
    notifyListeners();
  }


  //get position
  getPositionFen(){
    return game.fen;
  }


  //reset game
  void resetGame({required bool newGame}){
    if(newGame){
      //TODO check here if sami wants this??????
      // check if the player was white in the previous game
      // change the player
      // if(_player == Squares.white){
      //   _player = Squares.black;
      // }else{
      //   _player = Squares.white;
      // }
     notifyListeners();
    }
    //reset game
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);

    _whiteTimer?.cancel();
    _blackTimer?.cancel();
    _whiteTimer = null;
    _blackTimer = null;

    // Notify listeners about the state change
    // notifyListeners();
  }

  //make a move in the squares
  bool makeSquaresMove(move){
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  //make string move
  bool makeStringMove(String bestMove){
    bool result = game.makeMoveString(bestMove);
    notifyListeners();
    return result;
  }
  //set squares state
  Future<void> setSquaresState()async{
    _state = game.squaresState(player);
    notifyListeners();
  }

  //make random move
  void makeRandomMove(){
    _game.makeRandomMove();
    notifyListeners();
  }
  void flipTheBoard(){
    _flipBoard =!_flipBoard;
    notifyListeners();
  }

  void setAiThinking(bool value){
    _aiThinking = value;
    notifyListeners();
  }

  //set incremental value
  void setIncrementalValue({required int value}){
    _incrementalValue = value;
    notifyListeners();
  }

  //set vs computer
  void setVsComputer({required bool value}){
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }
  //set the get time
  Future<void> setGameTime({
    required String newSavedWhiteTime,
    required String newSavedBlackTime,

  })async{
    //save the times
    _whiteSavedTime = Duration(minutes: int.parse(newSavedWhiteTime));
    _blackSavedTime = Duration(minutes: int.parse(newSavedBlackTime));
    notifyListeners();
    //set times
    setWhiteTime(_whiteSavedTime);
    setBlackTime(_blackSavedTime);
  }

  void setWhiteTime(Duration time){
    _whiteTime = time;
    notifyListeners();
  }
  void setBlackTime(Duration time){
    _blackTime = time;
    notifyListeners();
  }

  //set player colors
  void setPlayerColor({required int player}){
    _player = player;
    _playerColor =
        player == Squares.white ? PlayerColor.white : PlayerColor.black;
        notifyListeners();
  }

  //set game difficulty
  void setDifficulty({required int level}){
    _gameLevel = level;
    _gameDifficulty = level ==1 ?
    GameDifficulty.easy : level ==2 ?
    GameDifficulty.medium : GameDifficulty.hard;
    notifyListeners();
  }

  //pause white's timer
  void pauseWhiteTimer(){
    if(_whiteTimer !=null){
      _whiteTime += Duration(seconds: _incrementalValue);
      _whiteTimer!.cancel();
      notifyListeners();
    }

  }
  //pause black's timer
  void pauseBlackTimer(){
    if(_blackTimer !=null){
      _blackTime += Duration(seconds: _incrementalValue);
      _blackTimer!.cancel();
      notifyListeners();
    }
  }

  //start black's timer
  void startBlacksTimer({
    required BuildContext context,
    required Function onNewGame,
    Stockfish ? stockfish,
  }) {
    _blackTimer = Timer.periodic(const Duration(seconds: 1),(_){
      _blackTime = _blackTime - const Duration(seconds: 1);
      notifyListeners();
      if(_blackTime <= Duration.zero){
        //black has lost
        _blackTimer!.cancel();
        notifyListeners();

        //show game over dialog
        if(context.mounted){
          gameOverDialog(
              context: context,
              stockfish: stockfish,
              timeOut: true,
              whiteWon: true,
              onNewGame: onNewGame);
        }
      }
    });
  }

  //start white's timer
  void startWhitesTimer({
    required BuildContext context,
    required Function onNewGame,
    Stockfish? stockfish,
  }) {
    _whiteTimer = Timer.periodic(const Duration(seconds: 1),(_){
      _whiteTime = _whiteTime - const Duration(seconds: 1);
      notifyListeners();
      if(_whiteTime <= Duration.zero){
        //white has lost
        _whiteTimer!.cancel();
        notifyListeners();
        //show game over dialog
        if(context.mounted){
          gameOverDialog(
              context: context,
              timeOut: true,
              stockfish: stockfish,
              whiteWon: false,
              onNewGame: onNewGame);
        }
      }
    });
  }

  // void gameOverListener({
  //   required BuildContext context,
  //   required Function onNewGame,
  //   Stockfish? stockfish,
  // }){
  //   if(game.gameOver){
  //     if(stockfish != null){
  //       stockfish.stdin = UCICommands.stop;
  //     }
  //     //pause both timers
  //     pauseWhiteTimer();
  //     pauseBlackTimer();
  //   }
  //   if(context.mounted){
  //     gameOverDialog(
  //         context: context,
  //         stockfish: stockfish,
  //         timeOut: false,
  //         whiteWon: false,
  //         onNewGame: onNewGame);
  //       }
  // }
  void gameOverListener({
    required BuildContext context,
    required Function onNewGame,
    Stockfish? stockfish,
  }){
    if(_vsComputer && !_aiThinking) {
      // Only check for game over if it's the player's turn and not waiting for AI move
      if(game.gameOver){
        if(stockfish != null){
          stockfish.stdin = UCICommands.stop;
        }
        //pause both timers
        pauseWhiteTimer();
        pauseBlackTimer();
        if(context.mounted){
          gameOverDialog(
              context: context,
              stockfish: stockfish,
              timeOut: false,
              whiteWon: false,
              onNewGame: onNewGame);
        }
      }
    }
  }



  //GameOver dialog
  void gameOverDialog({
    required BuildContext context,
    required bool timeOut,
    required bool whiteWon,
    required Function onNewGame,
    Stockfish ? stockfish,
  }) {
    //stop stockfish engine

    if(stockfish != null){
      stockfish.stdin = UCICommands.stop;
    }

    String resultsToShow = '';
    int whiteScoreToShow = 0;
    int blackScoreToShow = 0;

    //check if timed out
    if (timeOut) {
      //check who won and show the score
      if (whiteWon) {
        resultsToShow = 'White Won on Time';
        whiteScoreToShow = _whiteScore + 1;
      }
      if (!whiteWon) {
        resultsToShow = 'Black Won on Time';
        blackScoreToShow = _blackScore + 1;
      }
    }
    else {
      //it's not timed out yet...
      if (game.result != null) {
      resultsToShow = game.result!.readable;

      if (game.drawn) {
        //game is a draw
        String whiteResults = game.result!
            .scoreString
            .split('-')
            .first;
        String blackResults = game.result!
            .scoreString
            .split('-')
            .last;
        whiteScoreToShow = _whiteScore += int.parse(whiteResults);
        blackScoreToShow = _blackScore += int.parse(blackResults);
      } else if (game.winner == 0) {
        //meaning white is the winner
        String whiteResults = game.result!
            .scoreString
            .split('-')
            .first;
        whiteScoreToShow = _whiteScore += int.parse(whiteResults);
      }
      else if (game.winner == 1) {
        String blackResults = game.result!
            .scoreString
            .split('-')
            .last;
        blackScoreToShow = _blackScore += int.parse(blackResults);
      }
      else if (game.stalemate) {
        whiteScoreToShow = whiteScore;
        blackScoreToShow = blackScore;
      }
    }
  }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Game Over\n $whiteScoreToShow - $blackScoreToShow',
            textAlign: TextAlign.center,),
              content: Text(
                resultsToShow.isNotEmpty ? resultsToShow : 'Game is still in progress',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                    onPressed: (){
                    Navigator.pop(context);
                    //Navigate to home Screen
                    Navigator.pushNamedAndRemoveUntil(
                        context, Constants.homeScreen, (route) => false,);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),),),

                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    //reset the game
                  },
                  child: const Text(
                    'New Game',),),
              ],
        ),);
  }

}
