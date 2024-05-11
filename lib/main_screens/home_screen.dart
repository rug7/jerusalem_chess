import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:flutter_chess_1/main_screens/about_screen.dart';
import 'package:flutter_chess_1/main_screens/game_time_screen.dart';
import 'package:flutter_chess_1/main_screens/settings_screen.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


import '../helper/helper_methods.dart';
import 'color_option_screen.dart';

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
    setState(() {
      _translations = jsonContent;
    });
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

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    // final themeLanguageProvider = context.watch<ThemeLanguageProvider>();
    final isLightMode = _themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF663d99),
        title: Text(
          getTranslation('homeTitle', _translations),
          style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode,),
            color: isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language, color: textColor),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
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
              label: getTranslation('about', _translations),
              icon: Icons.info_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
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
          ],
        ),
      ),
      // Update the bottomNavigationBar in the HomeScreen to match the second screen
      bottomNavigationBar: Container(
        color: const Color(0xFF663d99),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              icon: SvgPicture.asset('assets/images/black_logo.svg', height: 50),
            ),
          ],
        ),
      ),

    );


  }
}

