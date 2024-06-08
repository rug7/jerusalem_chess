import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_1/providers/game_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squares/squares.dart';

Widget buildGameType(
    {required String label,
    String? gameTime,
    IconData? icon,
    required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Card(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon != null ? Icon(icon) :gameTime! =='60+0'? const SizedBox.shrink() : Text(gameTime),
        const SizedBox(
          height: 10,
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ]),
    ),
  );
}

String getTimerToDisplay({
  required GameProvider gameProvider,
  required bool isUser}){
  String timer ='';
  //check if it's a user
  if(isUser){
    if(gameProvider.player == Squares.white){
    timer = gameProvider.whiteTime.toString().substring(2,7);

    }
    if(gameProvider.player == Squares.black){
    timer = gameProvider.blackTime .toString().substring(2,7);
   }
  } else {
    //other -AI or another user
    if(gameProvider.player == Squares.white){
      timer = gameProvider.blackTime.toString().substring(2,7);

    }
    if(gameProvider.player == Squares.black){
      timer = gameProvider.whiteTime.toString().substring(2,7);
    }
  }
  return timer;

}

final List<String> gameTimes = [
  'Bullet 1+0',
  'Bullet 2+1',
  'Blitz 3+0',
  'Blitz 3+2',
  'Blitz 5+0',
  'Blitz 5+3',
  'Rapid 10+0',
  'Rapid 10+5',
  'Rapid 15+10',
  'Classical 30+0',
  'Classical 30+20',
  'Custom 60+0',
];

final List<String> arabicGameTimes = [
  'طلقة 1+0',
  'طلقة 2+1',
  'خاطف 3+0',
  'خاطف 3+2',
  'خاطف 5+0',
  'خاطف 5+3',
  'سريع 10+0',
  'سريع 10+5',
  'سريع 15+10',
  'كلاسيكي 30+0',
  'كلاسيكي 30+20',
  'مخصص 60+0',
];

var textFormDecoration = InputDecoration(
    hintText: 'Enter your email',
    labelText: 'Enter your email',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xff663d99),width: 2),
      borderRadius:BorderRadius.circular(8),),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xfff0c230),width: 2),)

);

//pick an image
Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
})async{
  File? fileImage;
  if(fromCamera){
    try{
      final takenPhoto = await ImagePicker().pickImage(source: ImageSource.camera);

      if(takenPhoto != null){
        fileImage = File(takenPhoto.path);
      }
    }catch(e){
      onFail(e.toString());
    }
  }
  else{
    try{
      final chooseAnImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if(chooseAnImage != null){
        fileImage = File(chooseAnImage.path);
      }
    }catch(e){
      onFail(e.toString());
    }

  }
  return fileImage;
}

//validate email method
bool validateEmail(String email){
  //Regular expression for email validation
  final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  //check if the email matches the regular expression
  return emailRegExp.hasMatch(email);
}

//load from json files
Future<Map<String, dynamic>> loadTranslations(String language) async {
  String content;
  try {
    content = await rootBundle.loadString('assets/language_translate/translations_$language.json');
  } catch (e) {
    print('Error loading translations: $e');
    return {};
  }
  return json.decode(content);
}
//implement translation functions
String getTranslation(String key, Map<String, dynamic> translations) {
  return translations[key] ?? key;
}

