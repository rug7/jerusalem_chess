import 'package:flutter/material.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../helper/helper_methods.dart';

import 'color_option_screen.dart';
import 'home_screen.dart';

class GameTimeScreen extends StatefulWidget {
  const GameTimeScreen({Key? key});

  @override
  State<GameTimeScreen> createState() => _GameTimeScreenState();
}

class _GameTimeScreenState extends State<GameTimeScreen> {
  late Map<String, dynamic> _translations;

  late ThemeLanguageProvider _themeLanguageProvider;
  late bool _isLightMode; // Track the light mode
  late List<String> _gameTimes; // Track game times based on language

  @override
  void initState() {
    super.initState();
    _translations = {};
    _isLightMode = false;
    _gameTimes = [];
  }

  Future<void> _loadTranslations() async {
    final language = _themeLanguageProvider.currentLanguage;
    final jsonContent = await loadTranslations(language);
    setState(() {
      _translations = jsonContent;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = context.read<ThemeLanguageProvider>();
    _isLightMode = _themeLanguageProvider.isLightMode;
    _gameTimes = _themeLanguageProvider.currentLanguage == 'Arabic'
        ? arabicGameTimes
        : gameTimes;
    _loadTranslations();
    _themeLanguageProvider.addListener(_themeChangeListener);
    _themeLanguageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Dispose the listener to avoid memory leaks
    // final themeLanguageProvider = context.read<ThemeLanguageProvider>();
    _themeLanguageProvider.removeListener(_onLanguageChanged);
    _themeLanguageProvider.removeListener(_themeChangeListener);
    super.dispose();
  }

  // Function to handle language changes
  void _onLanguageChanged() {
    _loadTranslations(); // Reload translations when the language changes
  }

  // Listener function to handle theme changes
  void _themeChangeListener() {
    setState(() {
      _isLightMode = _themeLanguageProvider.isLightMode;
      // Update game times based on the current language
      _gameTimes = _themeLanguageProvider.currentLanguage == 'Arabic'
          ? arabicGameTimes
          : gameTimes;
    });
  }


  @override
  Widget build(BuildContext context) {
    final bool isLightMode = _themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.white : Colors.black;
    final oppColor = isLightMode ? Colors.black : Colors.white;
    final cardColor = _themeLanguageProvider.isLightMode ? const Color(0xfff0f5f7) : const Color(0xff1e1e1e);


    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('chooseGameTime', _translations,),
          style: const TextStyle(color: Colors.white,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(_isLightMode ? Icons.light_mode : Icons.dark_mode),
            color: _isLightMode ? const Color(0xfff0c230) : const Color(
                0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          PopupMenuButton<String>(
            icon:const  Icon(Icons.language, color: Colors.white),
            onSelected: _themeLanguageProvider.changeLanguage,
            itemBuilder: (BuildContext context) =>
            [
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemCount: _gameTimes.length,
                itemBuilder: (context, index) {
                  final String label = _gameTimes[index].split(' ')[0];
                  final String gameTime = _gameTimes[index].split(' ')[1];
                  return buildGameType(
                    cardColor: cardColor,
                    label: label,
                    gameTime: gameTime,
                    onTap: () {
                      if (label == Constants.custom || label == Constants.arabicCustom) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ColorOptionScreen(
                                  isCustomTime: true,
                                  gameTime: gameTime,
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ColorOptionScreen(
                                  isCustomTime: false,
                                  gameTime: gameTime,
                                ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
