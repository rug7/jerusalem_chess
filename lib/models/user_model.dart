import 'package:flutter_chess_1/constants.dart';

class UserModel{
  String uid;
  String name;
  String email;
  String image;
  String createdAt;
  int playerRating;
  int gamesPlayed;
  int wins;
  int losses;
  List<Map<String, dynamic>> gameHistory;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.createdAt,
    required this.playerRating,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.gameHistory = const [], // Initialize game history as empty list

  });

  Map<String,dynamic> toMap(){
    return{
      Constants.uid : uid,
      Constants.name : name,
      Constants.email : email,
      Constants.image : image,
      Constants.createdAt : createdAt,
      Constants.playerRating: playerRating,
      Constants.gamesPlayed: gamesPlayed,
      Constants.wins: wins,
      Constants.losses: losses,
      Constants.gameHistory: gameHistory, // Include game history in the map

    };
  }

  factory UserModel.fromMap(Map<String,dynamic>data){
    var gameHistoryFromData = data[Constants.gameHistory] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> gameHistoryList = gameHistoryFromData.map((game) => Map<String, dynamic>.from(game)).toList();
    return UserModel(
        uid: data[Constants.uid] ?? '',
        name: data[Constants.name] ?? '',
        email: data[Constants.email] ?? '',
        image: data[Constants.image] ?? '',
        createdAt: data[Constants.createdAt] ?? '',
        playerRating: data[Constants.playerRating] ?? 0,
      gamesPlayed: data[Constants.gamesPlayed] ?? 0,
      wins: data[Constants.wins] ?? 0,
      losses: data[Constants.losses] ?? 0,
      gameHistory: gameHistoryList
    );
  }

  void updateRating(int opponentRating, bool won) {
    gamesPlayed++;
    if (won) {
      wins++;
      playerRating = ((playerRating * (gamesPlayed - 1)) + opponentRating + 400) ~/ gamesPlayed;
    } else {
      losses++;
      playerRating = ((playerRating * (gamesPlayed - 1)) + opponentRating - 400) ~/ gamesPlayed;
    }
  }

  // Method to add a new game to the user's game history
  void addGameToHistory({
    required String opponentName,
    required String creationTime,
    required String moves,
  }) {
    gameHistory.add({
      'opponentName': opponentName,
      'creationTime': creationTime,
      'moves': moves,
    });
  }

  // Method to remove a game from the user's game history
  void removeGameFromHistory(int index) {
    gameHistory.removeAt(index);
  }

}