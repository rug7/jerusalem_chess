import 'package:flutter/material.dart';
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
  late ThemeLanguageProvider _themeLanguageProvider; // Add this line

  @override
  void initState() {
    super.initState();
    _translations = {}; // Initialize translations map
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = context.read<ThemeLanguageProvider>(); // Initialize theme language provider
    // Load translations when the screen initializes
    _loadTranslations();
    // Listen for changes in language and reload translations accordingly
    _themeLanguageProvider.addListener(_onLanguageChanged);
  }

  // Load translations from JSON files based on the current language
  Future<void> _loadTranslations() async {
    final language = _themeLanguageProvider.currentLanguage; // Use _themeLanguageProvider here
    final jsonContent = await loadTranslations(language);
    if(mounted){
      setState(() {
        _translations = jsonContent;
      });
    }
  }

  @override
  void dispose() {
    // Dispose the listener to avoid memory leaks
    _themeLanguageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // Function to handle language changes
  void _onLanguageChanged() {
    _loadTranslations(); // Reload translations when the language changes
  }

  // Function to get greeting based on current time
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
    final textColor = isLightMode ? Colors.white : Colors.black;

    final user = context.watch<AuthenticationProvider>().userModel;

    return Scaffold(
      backgroundColor: textColor,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final itemHeight = (constraints.maxHeight - 32) / 3; // 3 rows with padding
          final itemWidth = (constraints.maxWidth - 16) / 2; // 2 columns with padding

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: itemWidth / itemHeight,
              children: [
                buildGameType(
                  label: getTranslation('playAgainstComputer', _translations),
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
                  icon: Icons.history,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameHistoryScreen()),
                    );
                  },
                ),
                buildGameType(
                  label: getTranslation('settings', _translations),
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                buildGameType(
                  label: getTranslation('news', _translations), // New "News" option
                  icon: Icons.newspaper,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewsScreen()), // Navigate to NewsScreen
                    );
                  },
                ),
                buildGameType(
                  label: getTranslation('communication', _translations), // New "Connect" option
                  icon: Icons.message,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunicationScreen()), // Navigate to ConnectScreen
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
