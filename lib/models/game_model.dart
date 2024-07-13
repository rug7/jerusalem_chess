import 'package:squares/squares.dart';
import '../constants.dart';

class GameModel{
  String gameId;
  String gameCreatorUid;
  String gameCreatorName;
  String userId;
  String userName;
  String positionFen;
  String winnerId;
  String whitesTime;
  String blacksTime;
  String whitesCurrentMove;
  String blacksCurrentMove;
  String boardState;
  String playState;
  String dateCreated;
  bool isWhitesTurn;
  bool isGameOver;
  int squareState;
  List<Move> moves;

  GameModel({
    required this.gameId,
    required this.gameCreatorUid,
    required this.gameCreatorName,
    required this.userId,
    required this.userName,
    required this.positionFen,
    required this.winnerId,
    required this.whitesTime,
    required this.blacksTime,
    required this.whitesCurrentMove,
    required this.blacksCurrentMove,
    required this.boardState,
    required this.playState,
    required this.dateCreated,
    required this.isWhitesTurn,
    required this.isGameOver,
    required this.squareState,
    required this.moves,
  });

  Map<String,dynamic> toMap(){
    return{
      Constants.gameId : gameId,
      Constants.gameCreatorUid : gameCreatorUid,
      Constants.gameCreatorName : gameCreatorName,
      Constants.userId : userId,
      Constants.userName : userName,
      Constants.positionFen : positionFen,
      Constants.winnerId : winnerId,
      Constants.whitesTime : whitesTime,
      Constants.blacksTime : blacksTime,
      Constants.whitesCurrentMove : whitesCurrentMove,
      Constants.blacksCurrentMove : blacksCurrentMove,
      Constants.boardState : boardState,
      Constants.playState : playState,
      Constants.dateCreated : dateCreated,
      Constants.isWhitesTurn : isWhitesTurn,
      Constants.isGameOver : isGameOver,
      Constants.squareState : squareState,
      Constants.moves : moves.map((move) => move.toString()).toList(),

    };
  }

  factory GameModel.fromMap(Map<String,dynamic>map){
    return GameModel(
      gameId: map[Constants.gameId] ?? '',
      gameCreatorUid: map[Constants.gameCreatorUid] ?? '',
      gameCreatorName: map[Constants.gameCreatorName] ?? '',
      userId: map[Constants.userId] ?? '',
      userName: map[Constants.userName] ?? '',
      positionFen: map[Constants.positionFen] ?? '',
      winnerId: map[Constants.winnerId] ?? '',
      whitesTime: map[Constants.whitesTime] ?? '',
      blacksTime: map[Constants.blacksTime] ?? '',
      whitesCurrentMove: map[Constants.whitesCurrentMove] ?? '',
      blacksCurrentMove: map[Constants.blacksCurrentMove] ?? '',
      boardState: map[Constants.boardState] ?? '',
      playState: map[Constants.playState] ?? '',
      dateCreated: map[Constants.dateCreated] ?? '',
      isWhitesTurn: map[Constants.isWhitesTurn] ?? false,
      isGameOver: map[Constants.isGameOver] ?? false,
      squareState: map[Constants.squareState] ?? 0,
      moves: List<Move>.from(map[Constants.moves] ?? []),
    );
  }

}