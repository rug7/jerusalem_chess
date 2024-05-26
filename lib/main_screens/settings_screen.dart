import 'package:flutter/material.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../authentication/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: const Text('Settings'),
       actions: [
         //log out button
         IconButton(
             onPressed: (){
               context.read<AuthenticationProvider>().sighOutUser().whenComplete((){
                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (context) => const LoginScreen()),
                       (Route<dynamic> route) => false,
                 );
               });
             },
             icon: const Icon(Icons.logout),),
       ],
     ),
      body: const Center(child: Text('Settings screen'),),
    );
  }
}
