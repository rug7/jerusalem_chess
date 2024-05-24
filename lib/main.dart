import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:flutter_chess_1/authentication/sign_up_screen.dart';
import 'package:flutter_chess_1/main_screens/about_screen.dart';
import 'package:flutter_chess_1/main_screens/game_screen.dart';
import 'package:flutter_chess_1/main_screens/game_time_screen.dart';
import 'package:flutter_chess_1/main_screens/home_screen.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chess_1/providers/theme_language_provider.dart';

import 'constants.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeLanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),

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



// import 'package:flutter/material.dart';
// import 'package:flutter_chess_1/authentication/login_screen.dart';
// import 'package:flutter_chess_1/providers/theme_language_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:lottie/lottie.dart';
// import 'package:firebase_core/firebase_core.dart';
//
//
// import 'authentication/sign_up_screen.dart';
// import 'firebase_options.dart'; // Assuming you have this file
// import 'constants.dart';
// import 'main_screens/about_screen.dart';
// import 'main_screens/game_screen.dart';
// import 'main_screens/game_time_screen.dart';
// import 'main_screens/home_screen.dart'; // Assuming you have this file
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MultiProvider(
//     providers: [
//       ChangeNotifierProvider(create: (_) => ThemeLanguageProvider()),
//     ],
//     child: const MyApp(),
//   ));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeLanguageProvider>(context);
//
//     return MaterialApp(
//       title: 'شطرنج القدس',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       themeMode: themeProvider.useSystemTheme
//           ? ThemeMode.system
//           : (themeProvider.isLightMode ? ThemeMode.light : ThemeMode.dark),
//       initialRoute: Constants.splashScreen,
//       routes: {
//         Constants.splashScreen: (context) => const SplashScreen(),
//         Constants.homeScreen: (context) => const HomeScreen(),
//         Constants.gameScreen: (context) => const GameScreen(),
//         Constants.aboutScreen: (context) => const AboutScreen(),
//         Constants.settingScreen: (context) => const HomeScreen(),
//         Constants.gameTimeScreen: (context) => const GameTimeScreen(),
//         Constants.loginScreen: (context) => const LoginScreen(),
//         Constants.signUpScreen: (context) => const SignUpScreen(),
//       },
//     );
//   }
// }
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to the login screen after 10 seconds
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Lottie.asset(
//           'assets/animations/loading.json',
//           width: 400,
//           height: 400,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
