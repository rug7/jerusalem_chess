
import 'package:flutter/cupertino.dart';

class Constants {
  static const String custom = 'Custom';
  static const String arabicCustom ='مخصص';

  static const String homeScreen = '/homeScreen';
  static const String gameScreen = '/gameScreen';
  static const String landingScreen = '/landingScreen';
  static const String loadingScreen = '/loadingScreen';

  static const String settingScreen = '/settingScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String colorOptionScreen = '/colorOptionScreen';
  static const String gameTimeScreen = '/gameTimeScreen';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';

  static const String userInformationScreen = 'userInformationScreen';

  static const String uid = 'uid';
  static const String name = 'name';
  static const String image = 'image';
  static const String email = 'email';
  static const String createdAt = 'createdAt';

  static const String userImages = 'userImages';
  static const String users = 'users';

  static const String userModel = 'userModel';
  static const String playerRating = 'playerRating';
  static const String gameCreatorRating = 'gameCreatorRating';
  static const String userRating = 'userRating';


  static const String isSignedIn = 'isSignedIn';

  static const String availableGames = 'availableGames';

  static const String photoUrl = 'photoUrl';
  static const String gameCreatorUid = 'gameCreatorUid';
  static const String gameCreatorName = 'gameCreatorName';
  static const String gameCreatorImage = 'gameCreatorImage';
  static const String isPlaying = 'isPlaying';
  static const String gameId = 'gameId';
  static const String dateCreated = 'dateCreated';
  static const String whitesTime = 'whitesTime';
  static const String blacksTime = 'blacksTime';

  static const String userId = 'userId';
  static const String positionFen = 'positionFen';
  static const String winnerId = 'winnerId';
  static const String whitesCurrentMove = 'whitesCurrentMove';
  static const String blacksCurrentMove = 'blacksCurrentMove';
  static const String boardState = 'boardState';
  static const String playState = 'playState';
  static const String isWhitesTurn = 'isWhitesTurn';
  static const String isGameOver = 'isGameOver';
  static const String squareState = 'squareState';
  static const String moves = 'moves';

  static const String runningGames = 'runningGames';
  static const String game = 'game';

  static const String userName = 'userName';
  static const String userImage = 'userImage';
  static const String gameScore = 'gameScore';














}

enum PlayerColor{
  white,black
}
enum GameDifficulty{
  easy , medium, hard
}

enum SignType{
  emailAndPassword,
  guest,
  google,
  facebook,
}
