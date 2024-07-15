import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chess_1/main_screens/educational_screen.dart';
import 'package:flutter_chess_1/main_screens/game_history_screen.dart';
import 'package:flutter_chess_1/main_screens/communication_screen.dart';
import 'package:flutter_chess_1/main_screens/game_time_screen.dart';
import 'package:flutter_chess_1/main_screens/settings_screen.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';
import 'package:provider/provider.dart';
import '../helper/helper_methods.dart';
import '../providers/authentication_provider.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _translations;
  late ThemeLanguageProvider _themeLanguageProvider;

  @override
  void initState() {
    super.initState();
    _translations = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = context.read<ThemeLanguageProvider>();
    _loadTranslations();
    _themeLanguageProvider.addListener(_onLanguageChanged);
  }

  Future<void> _loadTranslations() async {
    final language = _themeLanguageProvider.currentLanguage;
    final jsonContent = await loadTranslations(language);
    setState(() {
      _translations = jsonContent;
    });
  }

  @override
  void dispose() {
    _themeLanguageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadTranslations();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return getTranslation("gm", _translations);
    } else if (hour < 18) {
      return getTranslation("ga", _translations);
    } else {
      return getTranslation("ge", _translations);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final isLightMode = _themeLanguageProvider.isLightMode;
    final backgroundColor = isLightMode ? Colors.white : Colors.black;
    final textColor = isLightMode ? Colors.black : Colors.white;
    final user = context.watch<AuthenticationProvider>().userModel;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final cardColor = _themeLanguageProvider.isLightMode ? const Color(0xfff0f5f7) : const Color(0xff1e1e1e);


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          user?.name != null
              ? '${_getGreeting()} ${user?.name}'
              : getTranslation('homeTitle', _translations),
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700),
          textDirection: _themeLanguageProvider.currentLanguage == 'Arabic'
              ? TextDirection.rtl
              : TextDirection.ltr,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLightMode ? Icons.light_mode : Icons.dark_mode,
            ),
            color: isLightMode
                ? const Color(0xfff0c230)
                : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: _themeLanguageProvider.changeLanguage,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildGameType(
                    label: getTranslation('playAgainstComputer', _translations),
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.computer,
                    onTap: () {
                      gameProvider.setVsComputer(value: true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameTimeScreen()),
                      );
                    },
                  ),
                  buildGameType(
                    label: getTranslation('multiplayer', _translations),
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.group,
                    onTap: () {
                      gameProvider.setVsComputer(value: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameTimeScreen()),
                      );
                    },
                  ),
                  buildGameType(
                    label: getTranslation('gameHistory', _translations),
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.history,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameHistoryScreen()),
                      );
                    },
                  ),
                  buildGameType(
                    label: getTranslation('edu', _translations),
                    icon: Icons.school,
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EducationalScreen()),
                      );
                    },
                  ),
                  buildGameType(
                    label: getTranslation('news', _translations),
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.newspaper,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewsScreen()),
                      );
                    },
                  ),
                  buildGameType(
                    label: getTranslation('communication', _translations),
                    iconColor: iconColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    icon: Icons.message,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CommunicationScreen()),
                      );
                    },
                  ),

                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 150,
                child: buildGameType(
                  label: getTranslation('settings', _translations),
                  iconColor: iconColor,
                  cardColor: cardColor,
                  textColor: textColor,
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameType({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
    required Color cardColor,
    required Color textColor
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40,color: iconColor,),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: textColor
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}