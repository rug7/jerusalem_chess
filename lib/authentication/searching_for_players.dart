import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchingScreen extends StatefulWidget {
  final String txt;
  const SearchingScreen({super.key, required this.txt});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: Lottie.asset('assets/animations/landing.json', height: 150, width: 150),
            ),
            const SizedBox(height: 20), // Add some space between the animation and the text
             Text(
              widget.txt,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }




}
