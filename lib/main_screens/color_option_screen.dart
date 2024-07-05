import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/searching_for_players.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../helper/helper_methods.dart';
import '../widgets/widgets.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';
import 'home_screen.dart';

class ColorOptionScreen extends StatefulWidget {
  const ColorOptionScreen({super.key, required  this.isCustomTime, required this.gameTime});
  final bool isCustomTime;
  final String gameTime;

  @override
  State<ColorOptionScreen> createState() => _ColorOptionScreenState();
}



class _ColorOptionScreenState extends State<ColorOptionScreen> {
  Map<String, dynamic> translations = {};
  late ThemeLanguageProvider _themeLanguageProvider; // Add ThemeLanguageProvider reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context); // Initialize ThemeLanguageProvider
    loadTranslations(_themeLanguageProvider.currentLanguage).then((value) {
      setState(() {
        translations = value;
      });
    });
  }

  void reloadTranslations(String language) {
    loadTranslations(language).then((value) {
      setState(() {
        translations = value;
      });
    });
  }

  PlayerColor playerColorGroup = PlayerColor.white;
  GameDifficulty gameLevel = GameDifficulty.easy;

  int whiteTime = 0;
  int blackTime = 0;

  @override
  Widget build(BuildContext context) {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.white : Colors.black;
    final oppColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: _themeLanguageProvider.isLightMode ? Colors.white : const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('setUpText', translations),
          style: const TextStyle(color: Colors.white, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(_themeLanguageProvider.isLightMode ? Icons.light_mode : Icons.dark_mode), // Use ThemeLanguageProvider
            color: _themeLanguageProvider.isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7), // Use ThemeLanguageProvider
            onPressed: _themeLanguageProvider.toggleThemeMode, // Use ThemeLanguageProvider
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String selectedLanguage) {
              _themeLanguageProvider.changeLanguage(selectedLanguage); // Use ThemeLanguageProvider
              reloadTranslations(selectedLanguage);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Arabic',
                child: Text('العربية'),
              ),
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                //radioListTitle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *0.5,
                      // child: PlayerColorRadiobutton(title: 'Play as ${PlayerColor.white.name}',
                      child: PlayerColorRadiobutton(
                        title: getTranslation('playAsWhiteText', translations),
                        value: PlayerColor.white,
                        groupValue: gameProvider.playerColor,
                        onChanged: (value){
                          gameProvider.setPlayerColor(player: 0);
                        },
                      ),
                    ),
                    widget.isCustomTime
                        ? BuildCustomTime(
                        time: whiteTime.toString(),
                        onLeftClick: (){
                          setState(() {
                            whiteTime--;
                          });
                        },
                        onRightClick: (){
                          setState(() {
                            whiteTime++;
                          });

                        })
                        :Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5,color: oppColor),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Padding( 
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            widget.gameTime,
                            style: TextStyle(
                                fontSize: 20,
                                color: oppColor),),),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *0.5,
                      // child: PlayerColorRadiobutton(title: 'Play as ${PlayerColor.black.name}',
                      child: PlayerColorRadiobutton(title: getTranslation('playAsBlackText', translations),
                        value: PlayerColor.black,
                        groupValue: gameProvider.playerColor,
                        onChanged: (value){
                          gameProvider.setPlayerColor(player: 1);

                        },
                      ),
                    ),

                    widget.isCustomTime
                        ? BuildCustomTime(
                        time: blackTime.toString(),
                        onLeftClick: (){
                          setState(() {
                            blackTime--;
                          });
                        },
                        onRightClick: (){
                          setState(() {
                            blackTime++;
                          });
                        }
                    )
                        :Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5,color: oppColor),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            widget.gameTime,
                            style: TextStyle(
                                fontSize: 20,
                                color: oppColor),),),
                      ),
                    ),
                  ],
                ),
                gameProvider.vsComputer ?
                Column(
                  children: [
                     Padding(
                      padding:  const EdgeInsets.all(8.0),
                      child:  Text(getTranslation('difficultyText', translations),style: TextStyle(color: oppColor,fontFamily: 'IBM Plex Sans Arabic',fontWeight: FontWeight.w700),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GameLevel(
                            title: getTranslation('easyMode', translations),
                            value: GameDifficulty.easy,
                            groupValue: gameProvider.gameDifficulty,
                            onChanged: (value){
                              gameProvider.setDifficulty(level: 1);
                            }),
                        const SizedBox(width: 10,),
                        GameLevel(
                            title: getTranslation('mediumMode', translations),
                            value: GameDifficulty.medium,
                            groupValue: gameProvider.gameDifficulty,
                            onChanged: (value){
                              gameProvider.setDifficulty(level: 2);
                            }),
                        const SizedBox(width: 10,),
                        GameLevel(
                            title: getTranslation('hardMode', translations),
                            value: GameDifficulty.hard,
                            groupValue: gameProvider.gameDifficulty,
                            onChanged: (value){
                              gameProvider.setDifficulty(level: 3);
                            })
                      ],
                    ),
                  ],
                )
                    : const SizedBox.shrink(),

                const SizedBox(height: 20,),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    gameProvider.isLoading
                        ? Lottie.asset(
                      'assets/animations/landing.json',
                      height: 200,
                      width: 200,
                    )
                        : ElevatedButton(
                      onPressed: () {
                        playGame(gameProvider: gameProvider);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                            }
                            return _themeLanguageProvider.isLightMode ? const Color(0xff4e3c96) : const Color(0xff4e3c96);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(
                        getTranslation('playText', translations),
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    gameProvider.isLoading
                        ? const SizedBox(height: 20) // Add space between the animation and the text
                        : Text(
                      gameProvider.waitingText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 30,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),
                gameProvider.vsComputer ? const SizedBox.shrink() : Text(gameProvider.waitingText),
              ],
            ),
          );
        },
      ),
    );
  }
  void playGame({
    required GameProvider gameProvider,
  })async{
    final userModel = context.read<AuthenticationProvider>().userModel;
    if (widget.isCustomTime){
      //check the timers if they are >0
      if(whiteTime<=0 || blackTime <= 0){
        showSnackBar(context: context, content: 'Time Cant be 0');
        return;
      }
      gameProvider.setIsLoading(value: true);

      //2. Save time and color for both players
      await gameProvider.setGameTime(
          newSavedWhiteTime: whiteTime.toString(),
          newSavedBlackTime: blackTime.toString()
      ).whenComplete(() {
        if(gameProvider.vsComputer){
          gameProvider.setIsLoading(value: false);
          //3.navigate to game
          Navigator.pushNamed(context, Constants.gameScreen);
        }
        else {
          //search for players
        }
      });
    } else{
      // not custom time
      //check if it's incremental time
      //get the value after the plus sign
      final String incrementalTime = widget.gameTime.split('+')[1];

      //get the value before the plus sign
      final String gameTime = widget.gameTime.split('+')[0];

      //check if incremental is = 0
      if(incrementalTime != '0'){
        //save the value
        gameProvider.setIncrementalValue(value: int.parse(incrementalTime));
      }
      gameProvider.setIsLoading(value: true);
      await gameProvider.setGameTime(
          newSavedWhiteTime: gameTime,
          newSavedBlackTime: gameTime,
      ).whenComplete((){
        if(gameProvider.vsComputer){
          gameProvider.setIsLoading(value: false);
          //3.navigate to game
          Navigator.pushNamed(context, Constants.gameScreen);
        }
        else {
          //search for players
          //TODO Online play
          gameProvider.searchForPlayer(
              userModel: userModel!,
              onSuccess: (){
                if(gameProvider.waitingText == 'جاري البحث عن لاعب، الرجاء الإنتظار'){
                  //gameProvider.waitingText == getTranslation('searching', translations);
                  //stay on this screen and wait
                  //TODO put an animation and navigate while waiting


                  gameProvider.checkIfOpponentJoined(
                      userModel: userModel,
                      onSuccess: (){
                        gameProvider.setIsLoading(value: false);
                        //navigate to game screen
                        Navigator.pushNamed(context, Constants.gameScreen);
                      });

                }else{
                  gameProvider.setIsLoading(value: false);
                  //navigate to game screen
                 Navigator.pushNamed(context, Constants.gameScreen);
                }

          }, onFail: (error){
            gameProvider.setIsLoading(value: false);
            showSnackBar(context: context, content: error);
          });
        }
      });
    }
  }
}





