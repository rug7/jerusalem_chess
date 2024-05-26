import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../main_screens/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  //check authentication - if isSignedIn or not
  void checkAuthenticationState() async {
    final authProvider = context.read<AuthenticationProvider>();

    if(await authProvider.checkIsSignedIn()){
      //get user's data from firestore
      await authProvider.getUserDataFromFireStore();
      //save user data to shared preferences -- local storage
      await authProvider.saveUserDataToSharedPref();
      //navigate to home screen
      navigate(isSignIn: true);
    }
    else{
      //navigate to the login screen
      navigate(isSignIn: false);
      }
    }


    @override
    void initState(){
    checkAuthenticationState();
    super.initState();
    }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: Lottie.asset('assets/animations/landing.json',height: 150,width: 150),
        ),

      ),
    );
  }


  void navigate({required bool isSignIn}) {
    if(isSignIn){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }else{
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }
}
