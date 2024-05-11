import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/theme_language_provider.dart';

class PlayerColorRadiobutton extends StatelessWidget {
  const PlayerColorRadiobutton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor = const Color(0xff26266a),
  });

  final String title;
  final PlayerColor value;
  final PlayerColor groupValue;
  final Function(PlayerColor?)? onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PlayerColor>(
        title:Text(
            title,
            style: const TextStyle(
            color: Colors.black ,
            fontWeight: FontWeight.bold)),
        value: value,
        dense: true,
        shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(10)
        ),
        contentPadding: EdgeInsets.zero,
        tileColor: Colors.grey[300],
        groupValue: groupValue,
        onChanged: onChanged,
      activeColor: activeColor,
    );
  }
}

class BuildCustomTime extends StatelessWidget {
  const BuildCustomTime({
    super.key,
    required this.time,
    required this.onLeftClick,
    required this.onRightClick,
  });

  final String time;
  final Function() onLeftClick;
  final Function() onRightClick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
            onTap: time == '0' ? null : onLeftClick,
            child: const Icon(Icons.arrow_back)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(width: 0.5,color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.purple),),),
            ),
          ),
        ),
        InkWell(
          onTap: onRightClick,
            child: const Icon(Icons.arrow_forward)),

      ],
    );
  }
}

class GameLevel extends StatelessWidget {
  const GameLevel({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor = const Color(0xff26266a),
  });

  final String title;
  final GameDifficulty value;
  final GameDifficulty groupValue;
  final Function(GameDifficulty?)? onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final capital = title[0].toUpperCase() + title.substring(1);
    return Expanded(
      child: RadioListTile<GameDifficulty>(
          title:Text(
            capital,
            style: const TextStyle(
                color: Colors.black ,
                fontWeight: FontWeight.bold),
          ),
          value: value,
          dense: true,
          shape: RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(10)
          ),
          contentPadding: EdgeInsets.zero,
          tileColor: Colors.grey[300],
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: activeColor,
      ),
    );
  }
}

class HaveAccountWidget extends StatelessWidget {

   const HaveAccountWidget({
    super.key,
    required this.label,
    required this.labelAction,
    required this.onPressed,
  });

  final String label;
  final String labelAction;
  final Function() onPressed;


  @override
  Widget build(BuildContext context) {
    final themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context, listen: false);
    final isLightMode = themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.black : Colors.white;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 16,color: textColor),textAlign: TextAlign.center,),

        TextButton(
            onPressed: onPressed,
            child: Text(
              labelAction,
              style: const TextStyle(
                color: Color(0xFF663d99),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ),
      ],
    );
  }
}


showSnackBar({required BuildContext context , required String content}){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
