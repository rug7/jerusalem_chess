import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:flutter_chess_1/authentication/sign_up_screen.dart';
import 'package:flutter_chess_1/main_screens/about_screen.dart';
import 'package:flutter_chess_1/main_screens/game_screen.dart';
import 'package:flutter_chess_1/main_screens/game_time_screen.dart';
import 'package:flutter_chess_1/main_screens/home_screen.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';

import 'constants.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeLanguageProvider()),
      ],
        child: const MyApp()),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeLanguageProvider>(context);

    return MaterialApp(
      title: 'شطرنج القدس',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.useSystemTheme ? ThemeMode.system : (themeProvider.isLightMode ? ThemeMode.light : ThemeMode.dark),
      // home: const HomeScreen(),
      initialRoute: Constants.loginScreen,
      routes: {
        Constants.homeScreen: (context) => const HomeScreen(),
        Constants.gameScreen: (context) => const GameScreen(),
        Constants.aboutScreen: (context) => const AboutScreen(),
        Constants.settingScreen: (context) => const HomeScreen(),
        Constants.gameTimeScreen: (context) => const GameTimeScreen(),
        Constants.loginScreen: (context) => const LoginScreen(),
        Constants.signUpScreen: (context) => const SignUpScreen(),

        // Constants.signUpScreen: (context) => const SignUp
      },
    );
  }
}



