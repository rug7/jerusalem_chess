import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/helper/uci_commands.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter_chess_1/models/game_model.dart';
import 'package:flutter_chess_1/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';
import 'package:stockfish/stockfish.dart';
import 'package:uuid/uuid.dart';

import '../main_screens/home_screen.dart';


class GameProvider extends ChangeNotifier{

  List<String> moveList = [];

  bool showAnalysisBoard = false; // State variable to control visibility
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  void toggleAnalysisBoard() {
    showAnalysisBoard = !showAnalysisBoard;
    notifyListeners();
  }
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

  String _gameId ='';
  String get gameId => _gameId;

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
    moveList.clear();
    showAnalysisBoard = false;
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
  void resetNewGame({required bool newGame}){
    moveList.clear();
    showAnalysisBoard = false;
    // if(newGame){
    //   // TODO check here if sami wants this??????
    //   // check if the player was white in the previous game
    //   // change the player
    //   if(_player == Squares.white){
    //     _player = Squares.black;
    //   }else{
    //     _player = Squares.white;
    //   }
    //
    //  notifyListeners();
    // }
    //reset game
    // if (newGame) {
    //   // Optionally switch the player color for the new game
    //   _player = _player == Squares.white ? Squares.black : Squares.white;
    // }
    // Reset game state
    // _game = bishop.Game(variant: bishop.Variant.standard());
    // _state = game.squaresState(_player);
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
    // Reset timers
    _whiteTimer?.cancel();
    _blackTimer?.cancel();
    _whiteTimer = null;
    _blackTimer = null;
    _whiteTime = _whiteSavedTime;
    _blackTime = _blackSavedTime;

    _aiThinking = false;
    _flipBoard = false;
    _playWhiteTimer = true;
    _playBlackTimer = true;

    notifyListeners();

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

        //Cancel the game stream subscription
        gameStreamSubscription!.cancel();
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
  }) async {
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

    // Save game to user history before deletion
    List<String> moves = _state.moves.map((move) => move.toString()).toList();
    await saveGameToUserHistory(gameId, moves);

    // Update ratings
    String winnerId = whiteWon ? gameCreatorUid : userId;
    await updateRatings(
    gameId: gameId,
    winnerId: winnerId,
    onSuccess: () {
      print('Ratings updated successfully');
    },
    onFail: (error) {
      print('Failed to update ratings: $error');
    },
    );

    // Delete the game from availableGames and runningGames
    await firebaseFirestore.collection(Constants.availableGames).doc(gameId).delete();
    await firebaseFirestore.collection(Constants.runningGames).doc(gameId).delete();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over\n $whiteScoreToShow - $blackScoreToShow',
          textAlign: TextAlign.center,
        ),
        content: Text(
          resultsToShow.isNotEmpty ? resultsToShow : 'Game is still in progress',
          textAlign: TextAlign.center,
        ),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,  // Added this line
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to home Screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Constants.homeScreen,
                            (route) => false,
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<GameProvider>().toggleAnalysisBoard();
                    },
                    child: const Text(
                      'Analysis Board',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
                // Flexible(
                //   child: TextButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //       // TODO 1- to clear the moveList, 2- to make the AI start first 3- to validate 4- to save the moveList to the Firebase
                //       resetNewGame(newGame: true);
                //       // reset the game
                //     },
                //     child: const Text('New Game',style: TextStyle(color: Colors.green)),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _waitingText = '';

  String get waitingText => _waitingText;

  setWaitingText(){
    _waitingText ='';
    notifyListeners();
  }

  //search for players
  Future searchForPlayer({
  required UserModel userModel,
  required Function() onSuccess,
  required Function(String) onFail,
})async{
    try{
      //get all available games
      final availableGames = await firebaseFirestore.collection(Constants.availableGames).get();

      //check if there are any available games
      if(availableGames.docs.isNotEmpty){
        final List<DocumentSnapshot> gamesList = availableGames
                                            .docs.where((element) => element[Constants.isPlaying] == false)
                                            .toList();

        //check if there are no games where isPlaying == false
        if(gamesList.isEmpty){
          //TODO THE GET TRANSLATIONS
          _waitingText ='جاري البحث عن لاعب، الرجاء الإنتظار';
              //getTranslation('searching', _translations);
          notifyListeners();
          // create a new game
          createNewGameInFireStore(
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        }else{
          //TODO THE GET TRANSLATIONS
          _waitingText = 'جارٍ الانضمام إلى اللعبة، الرجاء الانتظار';//getTranslation('joining', _translations);
          notifyListeners();
          //join a game
          joinGame(
            game: gamesList.first,
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        }

      }else{
        //TODO THE GET TRANSLATIONS
        _waitingText = 'جاري البحث عن لاعب، الرجاء الإنتظار';//getTranslation('searching', _translations);
        notifyListeners();
        //we don't have any available games - create a game
        createNewGameInFireStore(
          userModel: userModel,
          onSuccess: onSuccess,
          onFail: onFail,
        );
      }

    }on FirebaseException catch(e){
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }


  //create a game
  void createNewGameInFireStore({
    required UserModel userModel,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    //create a game id
    _gameId = const Uuid().v4();
    notifyListeners();

    try{
      await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .set({
        Constants.uid: '',
        Constants.name: '',
        Constants.photoUrl: '',
        Constants.userRating: 450,
        Constants.gameCreatorUid: userModel.uid,
        Constants.gameCreatorName: userModel.name,
        Constants.gameCreatorImage: userModel.image,
        Constants.gameCreatorRating: userModel.playerRating,
        Constants.isPlaying: false,
        Constants.gameId: gameId,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.whitesTime: _whiteSavedTime.toString(),
        Constants.blacksTime: _blackSavedTime.toString(),


      });
      onSuccess();
    }on FirebaseException catch(e){
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }

  }

  String _gameCreatorUid = '';
  String _gameCreatorName = '';
  String _gameCreatorPhoto = '';
  int _gameCreatorRating = 0;
  String _userId = '';
  String _userName = '';
  String _userPhoto = '';
  int _userRating = 0;

  String get gameCreatorUid => _gameCreatorUid;
  String get gameCreatorName => _gameCreatorName;
  String get gameCreatorPhoto => _gameCreatorPhoto;
  int get gameCreatorRating => _gameCreatorRating;
  String get userId => _userId;
  String get userName => _userName;
  String get userPhoto => _userPhoto;
  int get userRating => _userRating;



  //join game
  void joinGame({
    required DocumentSnapshot<Object?>game,
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
})async{
    try{
      final myGame = await firebaseFirestore.collection(Constants.availableGames).doc(userModel.uid).get();

      // get the data from the game we are joining
      _gameCreatorUid = game[Constants.gameCreatorUid];
      _gameCreatorName = game[Constants.gameCreatorName];
      _gameCreatorPhoto= game[Constants.gameCreatorImage];
      _gameCreatorRating = game[Constants.gameCreatorRating];
      _userId = userModel.uid;
      _userName= userModel.name;
      _userPhoto= userModel.image;
      _userRating = userModel.playerRating;

      _gameId = game[Constants.gameId];
      notifyListeners();

      if(myGame.exists){
        //delete my created game since we are joining another game
        await myGame.reference.delete();

      }
      //initialize the game model
      final gameModel = GameModel(
          gameId: _gameId,
          gameCreatorUid: _gameCreatorUid,
          userId: _userId,
          positionFen: getPositionFen(),
          winnerId: '',
          whitesTime: game[Constants.whitesTime],
          blacksTime: game[Constants.blacksTime],
          whitesCurrentMove: '',
          blacksCurrentMove: '',
          boardState: state.board.flipped().toString(),
          playState: PlayState.ourTurn.name.toString(),
          isWhitesTurn: true,
          isGameOver: false,
          squareState: state.player,
          moves: state.moves.toList(),
      );

      //create a game controller directory on firestore
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(_gameId)
          .collection(Constants.game)
          .doc(_gameId)
          .set(gameModel.toMap());

      //create a new game directory in firestore

      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(_gameId)
          .set({
        Constants.gameCreatorUid: _gameCreatorUid,
        Constants.gameCreatorName: _gameCreatorName,
        Constants.gameCreatorImage: _gameCreatorPhoto,
        Constants.gameCreatorRating: _gameCreatorRating,
        Constants.userId: _userId,
        Constants.userName: _userName,
        Constants.userImage: _userPhoto,
        Constants.userRating: _userRating,
        Constants.isPlaying: true,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.gameScore: '0-0',
      });

      //update game settings depending on the data of the game we are joining
      await setGameDataAndSettings(game: game, userModel: userModel);


    onSuccess();
    }on FirebaseException catch(e){
      onFail(e.toString());
    }

  }

  StreamSubscription? isPlayingStreamSubscription;

  //check if the other player joined
  void checkIfOpponentJoined({
    required UserModel userModel,
    required Function() onSuccess,
  })async{
    isPlayingStreamSubscription = firebaseFirestore.collection(Constants.availableGames).doc(userModel.uid).snapshots().listen((event)async{
      //check if the game exists
      if(event.exists){
        final DocumentSnapshot game = event;

        //check if itPlaying = true
        if(game[Constants.isPlaying]){
          isPlayingStreamSubscription!.cancel();
          await Future.delayed(const Duration(milliseconds: 100));
          // get the data from the game we are joining
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _gameCreatorPhoto= game[Constants.gameCreatorImage];
          _userId = game[Constants.uid];
          _userName= game[Constants.name];
          _userPhoto= game[Constants.photoUrl];

          setPlayerColor(player: 0);
          notifyListeners();

          onSuccess();
        }
      }
    });
  }

  //set game data and settings
  Future<void> setGameDataAndSettings({
  required DocumentSnapshot<Object?>game,
  required UserModel userModel,  
  })async{
    //get the reference to the game we are joining
    final opponentsGame = firebaseFirestore
                                .collection(Constants.availableGames)
                                .doc(game[Constants.gameCreatorUid]);
    
    //time - 0:10:00.0000000
    List<String> whitesTimeParts = game[Constants.whitesTime].split(':');
    List<String> blacksTimeParts = game[Constants.blacksTime].split(':');
    
    int whitesGameTime = int.parse(whitesTimeParts[0]) * 60 + int.parse(whitesTimeParts[1]);
    int blacksGameTime = int.parse(blacksTimeParts[0]) * 60 + int.parse(blacksTimeParts[1]);
    
    //set game time
    await setGameTime(
        newSavedWhiteTime: whitesGameTime.toString(),
        newSavedBlackTime: blacksGameTime.toString()
    );
    
    //update the created game in firestore
    await opponentsGame.update({
      Constants.isPlaying: true,
      Constants.uid: userModel.uid,
      Constants.name: userModel.name,
      Constants.photoUrl: userModel.image,
      Constants.userRating: userModel.playerRating,
    });

    //set the player state
    setPlayerColor(player: 1);//setting to black
    notifyListeners();

  }

  bool _isWhitesTurn = true;
  String blacksMove ='';
  String whitesMove ='';

  bool get isWhitesTurn => _isWhitesTurn;

  StreamSubscription? gameStreamSubscription;

  //listen for game changes in firestore
  Future<void> listenForGameChanges({
    required BuildContext context,
    required UserModel userModel,
  })async{
    if(_vsComputer){
      return;
    }
    CollectionReference gameCollectionReference = firebaseFirestore
        .collection(Constants.runningGames)
        .doc(gameId)
        .collection(Constants.game);

    gameStreamSubscription = gameCollectionReference.snapshots().listen((event){
      if(event.docs.isNotEmpty){
        //get the game
        final DocumentSnapshot game = event.docs.first;
        try {

        //check if we are white - this means we are the game creator
        if(game[Constants.gameCreatorUid] ==  userModel.uid){
          //check if is white's turn
          if(game[Constants.isWhitesTurn]){
            _isWhitesTurn = true;

            //check if blacksCurrentMove is not empty or equal to the old move- this means blacks has played his move
            //this means it's our turn to play
            if(game[Constants.blacksCurrentMove] !=blacksMove){
              //update the whites UI

              Move convertedMove = convertMoveStringToMove(
                  moveString: game[Constants.blacksCurrentMove]
              );

              bool result = makeSquaresMove(convertedMove);//TODO update the moves in multiplayer , the move is game[Constants.blacksCurrentMove] and game[Constants.whitesCurrentMove]

              if(result){
                setSquaresState().whenComplete((){
                  pauseBlackTimer();
                  startWhitesTimer(context: context, onNewGame: (){});

                  gameOverListener(context: context, onNewGame: (){});
                });
              }
            }
            notifyListeners();
          }

        }else{
          //not the game creator
          _isWhitesTurn = false;

          //check if white has played his move
          if(game[Constants.whitesCurrentMove] !=whitesMove){
            //update the whites UI

            Move convertedMove = convertMoveStringToMove(
                moveString: game[Constants.whitesCurrentMove]
            );
            
            
            bool result = makeSquaresMove(convertedMove);//TODO update the moves in multiplayer , the move is game[Constants.blacksCurrentMove] and game[Constants.whitesCurrentMove]
            if(result){
              setSquaresState().whenComplete((){
                pauseWhiteTimer();
                startBlacksTimer(context: context, onNewGame: (){});

                gameOverListener(context: context, onNewGame: (){});
              });
            }
          }
          notifyListeners();
        }
        } catch (e) {
          print('Error processing game changes: $e');
        }
      }

    });
    FirebaseFirestore.instance.collection('games').doc(gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['playerLeft'] != null) {
          final playerLeftId = data['playerLeft'];
          if (playerLeftId != userModel.uid) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Player Left', textAlign: TextAlign.center),
                  content: const Text('Your opponent has left the game. You win!', textAlign: TextAlign.center),
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
            resetGame(newGame: true);
          }
        }
      }
    });
  }

  //convert move string to move format
  Move convertMoveStringToMove({
  required String moveString,
  }) {
    //Split the move string into it's components
    List<String> parts = moveString.split('-');

    //Extract 'from' and 'to'
    int from = int.parse(parts[0]);
    int to = int.parse(parts[1].split('[')[0]);

    String? promo;
    String? piece;
    //Extract the promotion 'promo' and 'piece' if available
    if(moveString.contains('[')){
      String extras = moveString.split('[')[1].split(']')[0];
      List<String> extraList = extras.split(',');
      promo = extraList[0];
      if(extraList.length > 1){
        piece = extraList[1];
      }
    }

    //Create and return a new Move object
    return Move(
        from: from,
        to: to,
        promo: promo,
        piece: piece
    );
  }

  //play move and save to firestore
  Future<void> playMoveAndSaveToFirestore({
    required BuildContext context,
    required Move move,
    required bool isWhitesMove,
  }) async{
    String currentUserId = isWhitesMove ? gameCreatorUid : userId;
    String opponentId = isWhitesMove ? userId : gameCreatorUid;
    String opponentName = isWhitesMove ? userName : gameCreatorName;
    String creationTime = DateTime.now().millisecondsSinceEpoch.toString();
    List<String> moves = [];

    final gameSnapshot = await firebaseFirestore
        .collection(Constants.runningGames)
        .doc(gameId)
        .collection(Constants.game)
        .doc(gameId)
        .get();
    if (gameSnapshot.exists) {
      final gameData = gameSnapshot.data() as Map<String, dynamic>;
      moves = (gameData[Constants.moves] as List<dynamic>).map((move) => move.toString()).toList();
    }

    // Add the current move to the moves list
    moves.add(convertMoveFormatProvider(move.toString()));

    //check if it's white's move
    if(isWhitesMove){
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positionFen: getPositionFen(),
        Constants.whitesCurrentMove : move.toString(),
        Constants.moves: FieldValue.arrayUnion([convertMoveFormatProvider(move.toString())]),
        Constants.isWhitesTurn: false,
        Constants.playState: PlayState.theirTurn.name.toString(),
        });

      //pause white's timer and start black's timer
      pauseWhiteTimer();
      Future.delayed(const Duration(milliseconds: 100)).whenComplete((){
        startBlacksTimer(
            context: context,
            onNewGame: (){

            });
      });
    }
    else{
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positionFen: getPositionFen(),
        Constants.blacksCurrentMove : move.toString(),
        Constants.moves: FieldValue.arrayUnion([convertMoveFormatProvider(move.toString())]),
        Constants.isWhitesTurn: true,
        Constants.playState: PlayState.ourTurn.name.toString(),
      });

      //pause black's timer and start black's timer
      pauseBlackTimer();
      Future.delayed(const Duration(milliseconds: 100)).whenComplete((){
        startWhitesTimer(
            context: context,
            onNewGame: (){

            });
      });
    }
    await saveMoveToUserHistory(
      gameId: gameId,
      userId: currentUserId,
      opponentId: opponentId,
      opponentName: opponentName,
      moves: moves,
      creationTime: creationTime,
    );


  }

  Future<void> saveMoveToUserHistory({
    required String gameId,
    required String userId,
    required String opponentId,
    required String opponentName,
    required List<String> moves,
    required String creationTime,
  }) async {
    try {
      final userSnapshot = await firebaseFirestore.collection(Constants.users).doc(userId).get();
      if (userSnapshot.exists) {
        List<dynamic> gameHistory = userSnapshot.data()![Constants.gameHistory] ?? [];

        // Check if the game already exists in the user's game history
        bool gameExists = false;
        for (var game in gameHistory) {
          if (game['opponentName'] == opponentName && game['creationTime'] == creationTime) {
            game['moves'] = moves;
            gameExists = true;
            break;
          }
        }

        // If the game does not exist, add a new entry
        if (!gameExists) {
          gameHistory.add({
            'opponentName': opponentName,
            'creationTime': creationTime,
            'moves': moves,
          });
        }

        await firebaseFirestore.collection(Constants.users).doc(userId).update({
          Constants.gameHistory: gameHistory,
        });
      }

      final opponentSnapshot = await firebaseFirestore.collection(Constants.users).doc(opponentId).get();
      if (opponentSnapshot.exists) {
        List<dynamic> opponentGameHistory = opponentSnapshot.data()![Constants.gameHistory] ?? [];

        // Check if the game already exists in the opponent's game history
        bool opponentGameExists = false;
        for (var game in opponentGameHistory) {
          if (game['opponentName'] == userId && game['creationTime'] == creationTime) {
            game['moves'] = moves;
            opponentGameExists = true;
            break;
          }
        }

        // If the game does not exist, add a new entry
        if (!opponentGameExists) {
          opponentGameHistory.add({
            'opponentName': userId,
            'creationTime': creationTime,
            'moves': moves,
          });
        }

        await firebaseFirestore.collection(Constants.users).doc(opponentId).update({
          Constants.gameHistory: opponentGameHistory,
        });
      }
    } catch (e) {
      print('Failed to save move to user history: $e');
    }
  }



  Future<void> leaveGame(String userId) async {
    final docRef = FirebaseFirestore.instance.collection(Constants.runningGames).doc(gameId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update({
          'playerLeft': userId,
          'gameStatus': 'opponentLeft', // Add a status field to indicate the game is over
          'isGameOver': true,
          'winnerId': 'opponent', // Set the opponent as the winner
        });
        // Save game to user history before deletion
        List<String> moves = (docSnapshot.data() as Map<String, dynamic>)[Constants.moves];
        await saveGameToUserHistory(gameId, moves);

        // Delete the game from availableGames and runningGames
        await firebaseFirestore.collection(Constants.availableGames).doc(gameId).delete();
        await firebaseFirestore.collection(Constants.runningGames).doc(gameId).delete();

      } else {
        print('Document not found: ${docRef.path}');
        // Handle the case where the document doesn't exist
      }
    } catch (e) {
      print('Error updating document: $e');
      // Handle any other errors that occur
    }
  }

  void listenForOpponentLeave(String gameId, BuildContext context) {
    FirebaseFirestore.instance.collection(Constants.runningGames).doc(gameId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data()!['gameStatus'] == 'opponentLeft'){
        // Show the opponent left message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('You Win!'),
            content: const Text('Your opponent has left the game.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<GameProvider>().toggleAnalysisBoard();
                },
                child: const Text(
                  'Analysis Board',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        );
      }
    });
    FirebaseFirestore.instance.collection(Constants.runningGames).doc(gameId).delete();
  }

  Stream<DocumentSnapshot> get gameMovesStream {
    if (gameId.isEmpty) {
      throw Exception("Game ID is not set");
    }
    return firebaseFirestore
        .collection(Constants.runningGames)
        .doc(gameId)
        .collection(Constants.game)
        .doc(gameId)
        .snapshots();
  }


  void listenToGameUpdates() {
    gameMovesStream.listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<dynamic> firestoreMoves = data[Constants.moves] ?? [];
          moveList = firestoreMoves.map((e) => (e.toString()).split('-')[1]).toList();
          notifyListeners(); // Notify listeners to update the UI
        }
      }
    });
  }

  String convertMoveFormatProvider(String move) {
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

  Future<void> updateRatings({
    required String gameId,
    required String winnerId,
    required Function onSuccess,
    required Function onFail,
  }) async {
    try {
      DocumentSnapshot gameSnapshot = await firebaseFirestore.collection(Constants.runningGames).doc(gameId).get();
      Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

      String gameCreatorUid = gameData[Constants.gameCreatorUid];
      String opponentUid = gameData[Constants.userId];
      int gameCreatorRating = gameData[Constants.gameCreatorRating];
      int opponentRating = gameData[Constants.userRating];

      // Determine the new ratings
      Map<String, int> newRatings = calculateNewRatings(
        gameCreatorRating: gameCreatorRating,
        opponentRating: opponentRating,
        winnerId: winnerId,
        gameCreatorUid: gameCreatorUid,
        opponentUid: opponentUid,
      );

      // Update the ratings in the database
      await firebaseFirestore.collection(Constants.users).doc(gameCreatorUid).update({
        Constants.userRating: newRatings[gameCreatorUid],
      });

      await firebaseFirestore.collection(Constants.users).doc(opponentUid).update({
        Constants.userRating: newRatings[opponentUid],
      });

      onSuccess();
    } catch (e) {
      onFail(e.toString());
    }
  }

  Map<String, int> calculateNewRatings({
    required int gameCreatorRating,
    required int opponentRating,
    required String winnerId,
    required String gameCreatorUid,
    required String opponentUid,
  }) {
    // Implement your rating calculation logic here
    const int kFactor = 32;

    double expectedScore(int ratingA, int ratingB) {
      return 1 / (1 + pow(10, (ratingB - ratingA) / 400));
    }

    double gameCreatorExpected = expectedScore(gameCreatorRating, opponentRating);
    double opponentExpected = expectedScore(opponentRating, gameCreatorRating);

    int gameCreatorNewRating = gameCreatorRating;
    int opponentNewRating = opponentRating;

    if (winnerId == gameCreatorUid) {
      gameCreatorNewRating += (kFactor * (1 - gameCreatorExpected)).round();
      opponentNewRating += (kFactor * (0 - opponentExpected)).round();
    } else if (winnerId == opponentUid) {
      gameCreatorNewRating += (kFactor * (0 - gameCreatorExpected)).round();
      opponentNewRating += (kFactor * (1 - opponentExpected)).round();
    } else {
      // Draw case
      gameCreatorNewRating += (kFactor * (0.5 - gameCreatorExpected)).round();
      opponentNewRating += (kFactor * (0.5 - opponentExpected)).round();
    }

    return {
      gameCreatorUid: gameCreatorNewRating,
      opponentUid: opponentNewRating,
    };
  }

  Future<void> saveGameToUserHistory(String gameId, List<String> moves) async {
    try {
      final gameSnapshot = await firebaseFirestore.collection(Constants.runningGames).doc(gameId).get();
      if (gameSnapshot.exists) {
        final gameData = gameSnapshot.data() as Map<String, dynamic>;

        String gameCreatorUid = gameData[Constants.gameCreatorUid];
        String opponentUid = gameData[Constants.userId];
        String gameCreatorName = gameData[Constants.gameCreatorName];
        String opponentName = gameData[Constants.userName];
        String creationTime = gameData[Constants.dateCreated];

        await firebaseFirestore.collection(Constants.users).doc(gameCreatorUid).update({
          Constants.gameHistory: FieldValue.arrayUnion([{
            'opponentName': opponentName,
            'creationTime': creationTime,
            'moves': moves,
          }])
        });

        await firebaseFirestore.collection(Constants.users).doc(opponentUid).update({
          Constants.gameHistory: FieldValue.arrayUnion([{
            'opponentName': gameCreatorName,
            'creationTime': creationTime,
            'moves': moves,
          }])
        });
      }
    } catch (e) {
      print('Failed to save game history: $e');
    }
  }

  Future<void> updateUserGameHistory(String userId, Map<String, dynamic> newGame) async {
    DocumentReference userRef = firebaseFirestore.collection(Constants.users).doc(userId);

    try {
      // Fetch the user data
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Update the user's game history
        List<dynamic> gameHistory = userData[Constants.gameHistory] ?? [];
        gameHistory.add(newGame);

        await userRef.update({
          Constants.gameHistory: gameHistory,
        });
      }
    } catch (e) {
      print('Error updating game history: $e');
    }
  }
  Future<void> endGame(String gameId, String winnerId, String player1Id, String player2Id, String moves) async {
    // Fetch user data
    DocumentSnapshot player1Snapshot = await firebaseFirestore.collection(Constants.users).doc(player1Id).get();
    DocumentSnapshot player2Snapshot = await firebaseFirestore.collection(Constants.users).doc(player2Id).get();

    if (player1Snapshot.exists && player2Snapshot.exists) {
      UserModel player1 = UserModel.fromMap(player1Snapshot.data() as Map<String, dynamic>);
      UserModel player2 = UserModel.fromMap(player2Snapshot.data() as Map<String, dynamic>);

      // Update ratings
      player1.updateRating(player2.playerRating, winnerId == player1Id);
      player2.updateRating(player1.playerRating, winnerId == player2Id);

      // Create game record
      Map<String, dynamic> gameRecord = {
        'opponentName': player2.name,
        'creationTime': DateTime.now().toString(),
        'moves': moves,
      };
      player1.addGameToHistory(
        opponentName: player2.name,
        creationTime: DateTime.now().toString(),
        moves: moves,
      );
      player2.addGameToHistory(
        opponentName: player1.name,
        creationTime: DateTime.now().toString(),
        moves: moves,
      );

      // Update Firestore
      await firebaseFirestore.collection(Constants.users).doc(player1Id).update(player1.toMap());
      await firebaseFirestore.collection(Constants.users).doc(player2Id).update(player2.toMap());
    }

    // Remove the game from Firestore
    await firebaseFirestore.collection(Constants.availableGames).doc(gameId).delete();
    await firebaseFirestore.collection(Constants.runningGames).doc(gameId).delete();
  }






}
